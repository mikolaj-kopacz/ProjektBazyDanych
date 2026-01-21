import psycopg2
import pandas as pd
import streamlit as st


# --- KONFIGURACJA I POMOCNICZE ---

def get_db_config():
    try:
        return st.secrets["postgres"]
    except Exception:
        return {
            "dbname": "wypozyczalnia_db",
            "user": "postgres",
            "password": "admin",
            "host": "localhost",
            "port": "5432",
        }


def get_connection():
    config = get_db_config()
    if isinstance(config, str):
        return psycopg2.connect(config)
    return psycopg2.connect(**config)


def run_query(query, params=None):
    """Wykonuje zapytanie SELECT i zwraca DataFrame."""
    conn = get_connection()
    try:
        df = pd.read_sql(query, conn, params=params)
        return df
    finally:
        conn.close()


def run_command(command, params=None):
    """Wykonuje zapytanie INSERT/UPDATE/DELETE/CALL."""
    conn = get_connection()
    cur = conn.cursor()
    try:
        cur.execute(command, params)
        conn.commit()
        return True, "Sukces"
    except Exception as e:
        conn.rollback()
        return False, str(e)
    finally:
        cur.close()
        conn.close()


# --- LOGOWANIE ---

def check_login(username, password):
    sql = "SELECT ID_Pracownika, Imie, Nazwisko, Stanowisko FROM Pracownicy WHERE Login=%s AND Haslo=%s"
    df = run_query(sql, (username, password))
    if not df.empty:
        return df.iloc[0].to_dict()
    return None


# --- PULPIT (STATYSTYKI) ---

def get_dashboard_stats():
    """Pobiera statystyki na pulpit: liczba aut, klientów, rezerwacji."""
    return run_query("SELECT * FROM fn_statystyki_pulpit()")


def get_monthly_occupancy(year, month):
    """Pobiera dane do wykresu obłożenia."""
    return run_query("SELECT * FROM OblozenieMiesieczne(%s, %s)", (year, month))


def get_urgent_alerts(mileage_limit=15000):
    """Pobiera auta wymagające serwisu."""
    return run_query("SELECT * FROM fn_pobierz_pojazdy_alert(%s)", (mileage_limit,))


# --- KLIENCI ---

def get_all_clients():
    """Pobiera listę wszystkich klientów."""
    return run_query("SELECT * FROM fn_pobierz_klientow()")


def get_client_id_by_pesel(pesel):
    try:
        res = run_query("SELECT fn_znajdz_klienta_pesel(%s) as id", (pesel,))
        if not res.empty and res.iloc[0]["id"]:
            return int(res.iloc[0]["id"])
        return None
    except Exception:
        return None


def add_new_client(imie, nazwisko, pesel, nr_prawa, telefon, email, adres):
    try:
        sql = "CALL sp_dodaj_klienta(%s, %s, %s, %s, %s, %s, %s);"
        success, msg = run_command(
            sql, (imie, nazwisko, pesel, nr_prawa, telefon, email, adres)
        )
        if success:
            return True, "Dodano klienta.", get_client_id_by_pesel(pesel)
        return False, msg, None
    except Exception as e:
        return False, f"Błąd: {str(e)}", None


def update_client(cid, imie, nazwisko, pesel, nr_prawa, telefon, email, adres):
    try:
        sql = "CALL sp_aktualizuj_klienta(%s, %s, %s, %s, %s, %s, %s, %s);"
        return run_command(sql, (cid, imie, nazwisko, pesel, nr_prawa, telefon, email, adres))
    except Exception as e:
        return False, f"Błąd: {str(e)}"


def delete_client(cid):
    try:
        sql = "CALL sp_usun_klienta(%s);"
        return run_command(sql, (cid,))
    except Exception as e:
        return False, f"Błąd: {str(e)}"


def get_client_history_json(client_id):
    return run_query("SELECT PobierzHistorieKlientaJSON(%s) as j", (client_id,))


def get_client_statuses():
    return run_query("SELECT * FROM StatusKlientow()")


def get_vip_ranking(limit=5):
    return run_query("SELECT * FROM RankingKlientowVIP(%s)", (limit,))


# --- POJAZDY I FLOTA ---

def get_all_vehicles():
    """Pobiera pełną listę pojazdów."""
    return run_query("SELECT * FROM fn_pobierz_pojazdy()")


def get_vehicle_classes():
    return run_query("SELECT * FROM fn_pobierz_klasy()")


def search_vehicles(phrase):
    """Wyszukuje pojazdy po frazie."""
    return run_query("SELECT * FROM SzukajPojazdu(%s)", (phrase,))


def find_available_vehicles(date_from, date_to):
    """Szuka aut dostępnych w zadanym terminie."""
    return run_query("SELECT * FROM ZnajdzDostepnePojazdy(%s, %s, NULL)", (date_from, date_to))


def add_vehicle(id_klasy, marka, model, rok, nr_rej, przebieg, stan, status):
    return run_command("CALL sp_dodaj_pojazd(%s, %s, %s, %s, %s, %s, %s, %s);",
                       (id_klasy, marka, model, rok, nr_rej, przebieg, stan, status))


def update_vehicle_status(id_pojazdu, przebieg, stan, status):
    return run_command("CALL sp_aktualizuj_pojazd(%s, NULL, NULL, NULL, NULL, NULL, %s, %s, %s);",
                       (id_pojazdu, przebieg, stan, status))


def delete_vehicle(id_pojazdu):
    res, msg = run_command("CALL sp_usun_pojazd(%s);", (id_pojazdu,))
    if not res and "historię rezerwacji" in msg:
        return False, "Nie można usunąć pojazdu z historią. Zmień status na 'Wycofany'."
    return res, msg


def add_service_entry(id_pojazdu, data, opis, koszt, przebieg):
    return run_command("CALL sp_dodaj_serwis(%s, %s, %s, %s, %s);", (id_pojazdu, data, opis, koszt, przebieg))


# --- REZERWACJE ---

def add_reservation(id_klienta, id_pojazdu, id_pracownika, data_start, data_end, cena):
    """Dodaje rezerwację wywołując procedurę."""
    import datetime
    today = datetime.date.today()


    return run_command(
        "CALL sp_dodaj_rezerwacje(%s, %s, %s, %s, %s, %s, %s, %s, %s);",
        (
            id_klienta,
            id_pojazdu,
            id_pracownika,
            today,  # Data rezerwacji (dzisiaj)
            data_start,  # Data od
            data_end,  # Data do
            "Siedziba",
            float(cena),
            "Potwierdzona"
        )
    )


# --- PRACOWNICY ---

def get_employees():
    return run_query("SELECT * FROM fn_pobierz_pracownikow()")


def get_employee_efficiency():
    return run_query("SELECT * FROM EfektywnoscPracownikow()")


def add_employee(imie, nazwisko, stanowisko, login, haslo):
    return run_command("CALL sp_dodaj_pracownika(%s, %s, %s, %s, %s);", (imie, nazwisko, stanowisko, login, haslo))


def update_employee(emp_id, imie, nazwisko, stanowisko):
    return run_command("CALL sp_aktualizuj_pracownika(%s, %s, %s, %s);", (emp_id, imie, nazwisko, stanowisko))


def delete_employee(emp_id):
    return run_command("CALL sp_usun_pracownika(%s);", (emp_id,))


# --- FINANSE ---

def get_revenue_report(year):
    return run_query("SELECT * FROM RaportPrzychodow(%s)", (year,))
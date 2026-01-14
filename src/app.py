import streamlit as st
import pandas as pd
from db import run_query, run_command, check_login
import datetime
import time
from fpdf import FPDF

st.set_page_config(
    page_title="System Wypożyczalni", layout="wide", initial_sidebar_state="expanded"
)

# --- CSS ---
st.markdown(
    """
    <style>
    .main .block-container { padding-top: 2rem; padding-bottom: 2rem; }
    div[data-testid="stMetric"] {
        background-color: #E3F2FD !important;
        border: 1px solid #90CAF9;
        padding: 15px;
        border-radius: 10px;
        box-shadow: 2px 2px 5px rgba(0,0,0,0.1);
    }
    div[data-testid="stMetric"] * { color: #0D47A1 !important; }
    .reservation-box {
        border: 2px solid #66BB6A;
        padding: 20px;
        border-radius: 12px;
        background-color: #E8F5E9 !important;
        box-shadow: 0 4px 6px rgba(0,0,0,0.1);
    }
    .reservation-box h3, .reservation-box p, .reservation-box b, .reservation-box span {
        color: #1B5E20 !important;
    }
    </style>
""",
    unsafe_allow_html=True,
)


# --- FUNKCJE POMOCNICZE (WRAPPERY NA BAZĘ) ---

def get_client_id_by_pesel(pesel):
    try:
        res = run_query("SELECT fn_znajdz_klienta_pesel(%s) as id", (pesel,))
        if not res.empty and res.iloc[0]["id"]:
            return res.iloc[0]["id"]
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


def clean_text(text):
    if not isinstance(text, str):
        text = str(text)
    replacements = {
        "ą": "a", "ć": "c", "ę": "e", "ł": "l", "ń": "n", "ó": "o", "ś": "s", "ź": "z", "ż": "z",
        "Ą": "A", "Ć": "C", "Ę": "E", "Ł": "L", "Ń": "N", "Ó": "O", "Ś": "S", "Ź": "Z", "Ż": "Z",
    }
    for k, v in replacements.items():
        text = text.replace(k, v)
    return text


def create_pdf_confirmation(klient_info, auto_info, data_od, data_do, cena, pracownik):
    try:
        pdf = FPDF()
        pdf.add_page()
        pdf.set_font("Arial", "B", 16)
        pdf.cell(0, 10, clean_text("Potwierdzenie Rezerwacji"), ln=True, align="C")
        pdf.ln(10)
        pdf.set_font("Arial", "", 12)
        pdf.cell(0, 10, clean_text(f"Data: {datetime.date.today()}"), ln=True)
        pdf.cell(0, 10, clean_text(f"Obsluga: {pracownik}"), ln=True)
        pdf.ln(5)
        pdf.set_font("Arial", "B", 12)
        pdf.cell(0, 10, clean_text("DANE KLIENTA:"), ln=True)
        pdf.set_font("Arial", "", 12)
        pdf.cell(0, 10, clean_text(f"Klient: {klient_info}"), ln=True)
        pdf.ln(5)
        pdf.set_font("Arial", "B", 12)
        pdf.cell(0, 10, clean_text("POJAZD:"), ln=True)
        pdf.set_font("Arial", "", 12)
        pdf.cell(0, 10, clean_text(f"{auto_info['marka']} {auto_info['model']} ({auto_info['nr_rej']})"), ln=True)
        pdf.ln(5)
        pdf.set_font("Arial", "B", 12)
        pdf.cell(0, 10, clean_text("TERMIN I KOSZT:"), ln=True)
        pdf.set_font("Arial", "", 12)
        pdf.cell(0, 10, clean_text(f"{data_od} - {data_do}"), ln=True)
        pdf.cell(0, 10, clean_text(f"Razem: {cena:.2f} PLN"), ln=True)
        return bytes(pdf.output())
    except Exception as e:
        print(f"Błąd PDF: {e}")
        return b""


# Wrapper Functions for other entities
def add_employee(imie, nazwisko, stanowisko, login, haslo):
    return run_command("CALL sp_dodaj_pracownika(%s, %s, %s, %s, %s);", (imie, nazwisko, stanowisko, login, haslo))


def update_employee(emp_id, imie, nazwisko, stanowisko):
    return run_command("CALL sp_aktualizuj_pracownika(%s, %s, %s, %s);", (emp_id, imie, nazwisko, stanowisko))


def delete_employee(emp_id):
    return run_command("CALL sp_usun_pracownika(%s);", (emp_id,))


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


# --- LOGIKA SESJI ---
if "logged_in" not in st.session_state:
    st.session_state["logged_in"] = False
if "user_info" not in st.session_state:
    st.session_state["user_info"] = {}
if "reservation_step" not in st.session_state:
    st.session_state["reservation_step"] = None
if "selected_car_data" not in st.session_state:
    st.session_state["selected_car_data"] = None
if "last_reservation_data" not in st.session_state:
    st.session_state["last_reservation_data"] = None

# ================= EKRAN LOGOWANIA =================
if not st.session_state["logged_in"]:
    c1, c2, c3 = st.columns([1, 1, 1])
    with c2:
        st.title("🔒 Logowanie")
        with st.form("login_form"):
            user = st.text_input("Login")
            pw = st.text_input("Hasło", type="password")
            if st.form_submit_button("Zaloguj się", type="primary", use_container_width=True):
                try:
                    user_data = check_login(user, pw)
                    if user_data:
                        st.session_state["logged_in"] = True
                        st.session_state["user_info"] = user_data
                        st.rerun()
                    else:
                        st.error("Błędny login lub hasło.")
                except Exception as e:
                    st.error(f"Błąd połączenia: {e}")
    st.stop()

# ================= GŁÓWNA APLIKACJA  =================
user_id = st.session_state["user_info"]["id_pracownika"]
user_name = st.session_state["user_info"]["imie"]
user_role = st.session_state["user_info"]["stanowisko"]

with st.sidebar:
    st.title("🚗 Rent-A-Car OS")
    st.success(f"👤 {user_name} ({user_role})")
    menu_options = ["🏠 Pulpit", "🚗 Flota & Rezerwacje", "👥 Klienci", "💰 Finanse"]
    if user_role == "Menadżer":
        menu_options.append("💼 Pracownicy (Admin)")
    menu = st.radio("Sekcje", menu_options)
    st.markdown("---")
    c1, c2 = st.columns(2)
    if c1.button("Wyloguj"):
        st.session_state.clear()
        st.rerun()
    if c2.button("Reset"):
        st.session_state["reservation_step"] = None
        st.rerun()

# ----------------- PULPIT -----------------
if menu == "🏠 Pulpit":
    if user_role == "Menadżer":
        st.title("🏠 Pulpit Menadżera")
    else:
        st.title("🏠 Pulpit")

    try:
        stats = run_query("SELECT * FROM fn_statystyki_pulpit()")
        if not stats.empty:
            count_cars = stats.iloc[0]["liczba_pojazdow"]
            count_clients = stats.iloc[0]["liczba_klientow"]
            count_reservations = stats.iloc[0]["aktywne_rezerwacje"]
        else:
            count_cars, count_clients, count_reservations = 0, 0, 0
    except:
        count_cars, count_clients, count_reservations = 0, 0, 0

    c1, c2, c3, c4 = st.columns(4)
    c1.metric("Wszystkie Pojazdy", count_cars)
    c2.metric("Baza Klientów", count_clients)
    c3.metric("Aktywne Wynajmy", count_reservations)
    c4.metric("Dostępne teraz", int(count_cars) - int(count_reservations))

    st.markdown("---")
    col_chart, col_alerts = st.columns([2, 1])

    with col_chart:
        st.subheader("📊 Obłożenie")
        try:
            now = datetime.date.today()
            df_chart = run_query("SELECT * FROM OblozenieMiesieczne(%s, %s)", (now.year, now.month))
            if not df_chart.empty:
                st.area_chart(df_chart.set_index("dzien")["liczba_aut"])
            else:
                st.info("Brak danych.")
        except Exception as e:
            st.error(f"Błąd wykresu: {e}")

    with col_alerts:
        st.subheader("⚠️ Pilne Sprawy (Serwis)")
        try:
            df_serv = run_query("SELECT * FROM fn_pobierz_pojazdy_alert(15000)")
            if not df_serv.empty:
                good_states = ["sprawny", "idealny", "bardzo dobry", "dobry", "nowy"]
                urgent = df_serv[
                    (df_serv["status_km"] != "✅ OK") |
                    (~df_serv["stan_faktyczny"].str.lower().str.strip().isin(good_states))
                    ]
                if not urgent.empty:
                    st.error(f"Auta do sprawdzenia: {len(urgent)}")
                    st.dataframe(urgent[["pojazd", "stan_faktyczny", "status_km"]], hide_index=True)
                else:
                    st.success("Wszystko OK.")
        except Exception as e:
            st.error(f"Błąd alertów: {e}")

# ----------------- FLOTA -----------------
elif menu == "🚗 Flota & Rezerwacje":
    st.title("🚗 Flota i Rezerwacje")
    tab_rez, tab_fleet, tab_analysis = st.tabs(["🔍 Wyszukiwanie", "🛠️ Flota", "📊 Analizy"])

    with tab_rez:
        if st.session_state["reservation_step"] is None:
            with st.container(border=True):
                st.subheader("1. Znajdź samochód")
                c1, c2, c3 = st.columns([2, 2, 1])
                d_od = c1.date_input("Data Odbioru", datetime.date.today())
                d_do = c2.date_input("Data Zwrotu", datetime.date.today() + datetime.timedelta(days=3))
                st.session_state["dates"] = (d_od, d_do)
                if c3.button("🔍 Szukaj", type="primary", use_container_width=True):
                    st.session_state["search_performed"] = True

            if st.session_state.get("search_performed"):
                try:
                    df_auta = run_query("SELECT * FROM ZnajdzDostepnePojazdy(%s, %s, NULL)", (d_od, d_do))
                    if df_auta.empty:
                        st.warning("Brak aut.")
                    else:
                        st.success(f"Znaleziono: {len(df_auta)}")
                        cols = st.columns(2)
                        for idx, row in df_auta.iterrows():
                            with cols[idx % 2]:
                                with st.container(border=True):
                                    st.markdown(f"### {row['marka']} {row['model']}")
                                    st.caption(f"{row['klasa']} | {row['nr_rej']}")
                                    days = (d_do - d_od).days or 1
                                    st.write(f"**{row['cena']} PLN/doba** | Razem: {days * row['cena']:.2f} PLN")
                                    if st.button("Rezerwuj", key=f"btn_{row['id_pojazdu']}"):
                                        st.session_state["reservation_step"] = "form"
                                        st.session_state["selected_car_data"] = row
                                        st.rerun()
                except Exception as e:
                    st.error(str(e))

        elif st.session_state["reservation_step"] == "form":
            car = st.session_state["selected_car_data"]
            d_start, d_end = st.session_state["dates"]
            price_total = ((d_end - d_start).days or 1) * car["cena"]

            st.markdown(f"### Rezerwacja: {car['marka']} {car['model']}")
            st.info(f"Termin: {d_start} - {d_end} | Cena: {price_total:.2f} PLN")

            method = st.radio("Klient:", ["Wybierz z bazy", "Nowy klient"], horizontal=True)
            sel_client_id = None
            client_str = ""

            with st.form("booking_form"):
                if method == "Wybierz z bazy":
                    try:
                        cdf = run_query("SELECT * FROM fn_pobierz_klientow()")
                        if not cdf.empty:
                            copts = {f"{r['nazwisko']} {r['imie']} ({r['pesel']})": r['id_klienta'] for i, r in
                                     cdf.iterrows()}
                            chosen = st.selectbox("Klient", list(copts.keys()))
                            if chosen:
                                sel_client_id = copts[chosen]
                                client_str = chosen
                        else:
                            st.warning("Pusta baza klientów.")
                    except Exception as e:
                        st.error(str(e))
                else:
                    c1, c2 = st.columns(2)
                    ni = c1.text_input("Imię")
                    nn = c2.text_input("Nazwisko")
                    np = c1.text_input("PESEL", max_chars=11)
                    npr = c2.text_input("Prawo Jazdy")
                    nt = c1.text_input("Telefon")
                    ne = c2.text_input("Email")
                    na = st.text_area("Adres")
                    client_str = f"{nn} {ni}"

                place = st.text_input("Miejsce odbioru", "Siedziba Główna")

                if st.form_submit_button("Potwierdź", type="primary"):
                    if method == "Nowy klient":
                        ok, msg, nid = add_new_client(ni, nn, np, npr, nt, ne, na)
                        if not ok:
                            st.error(msg)
                            st.stop()
                        sel_client_id = nid

                    res_ok, res_msg = run_command(
                        "CALL sp_dodaj_rezerwacje(%s, %s, %s, %s, %s, %s, %s, %s, %s);",
                        (sel_client_id, int(car["id_pojazdu"]), user_id, datetime.date.today(), d_start, d_end, place,
                         float(price_total), "Potwierdzona")
                    )
                    if res_ok:
                        st.session_state["reservation_step"] = "success"
                        st.session_state["last_reservation_data"] = {
                            "car": car, "client_name": client_str, "d_start": d_start, "d_end": d_end,
                            "price": price_total, "worker": user_name
                        }
                        st.rerun()
                    else:
                        st.error(res_msg)

            if st.button("Anuluj"):
                st.session_state["reservation_step"] = None
                st.rerun()

        elif st.session_state["reservation_step"] == "success":
            st.balloons()
            st.success("Rezerwacja udana!")
            data = st.session_state["last_reservation_data"]
            pdf = create_pdf_confirmation(data["client_name"], data["car"], data["d_start"], data["d_end"],
                                          data["price"], data["worker"])
            if pdf:
                st.download_button("Pobierz PDF", pdf, "rezerwacja.pdf", "application/pdf")
            if st.button("Wróć"):
                st.session_state["reservation_step"] = None
                st.rerun()

    with tab_fleet:
        st.subheader("🛠️ Zarządzanie Flotą")
        try:
            # 1. Pobieramy wszystkie auta
            all_cars = run_query("SELECT * FROM fn_pobierz_pojazdy()")
        except:
            all_cars = pd.DataFrame()

        # 2. WYŚWIETLAMY TABELĘ ZE WSZYSTKIMI AUTAMI (NOWOŚĆ)
        st.markdown("#### 📋 Lista Wszystkich Pojazdów")
        if not all_cars.empty:
            # Wybieramy tylko czytelne kolumny, żeby nie śmiecić ID klasy itp.
            st.dataframe(
                all_cars[
                    ["id_pojazdu", "marka", "model", "numer_rejestracyjny", "status_dostepnosci", "stan_techniczny",
                     "przebieg"]],
                use_container_width=True,
                hide_index=True
            )
        else:
            st.info("Brak pojazdów w bazie.")

        st.markdown("---")

        # 3. Sekcja Edycji i Zarządzania
        with st.container(border=True):
            st.markdown("#### 🔧 Szybka Edycja Stanu")
            if not all_cars.empty:
                opts = {f"#{r['id_pojazdu']} {r['marka']} {r['model']}": r['id_pojazdu'] for i, r in
                        all_cars.iterrows()}
                sel = st.selectbox("Wybierz auto", list(opts.keys()))
                if sel:
                    cid = opts[sel]
                    crow = all_cars[all_cars['id_pojazdu'] == cid].iloc[0]
                    with st.form("status_car"):
                        c1, c2, c3 = st.columns(3)
                        nst = c1.selectbox("Status", ["Dostępny", "W serwisie", "Wypożyczony"],
                                           index=["Dostępny", "W serwisie", "Wypożyczony"].index(
                                               crow["status_dostepnosci"]))
                        nkm = c2.number_input("Przebieg", value=int(crow["przebieg"]))
                        ntxt = c3.text_input("Stan Techniczny", value=crow["stan_techniczny"])
                        if st.form_submit_button("Zapisz"):
                            ok, msg = update_vehicle_status(int(cid), int(nkm), ntxt, nst)
                            if ok:
                                st.success("Zapisano")
                                time.sleep(1)
                                st.rerun()
                            else:
                                st.error(msg)

        if user_role == "Menadżer":
            st.markdown("#### ⚡ Opcje Menadżera")
            mt1, mt2, mt3 = st.tabs(["Dodaj", "Usuń", "Serwis"])
            with mt1:
                with st.form("new_car"):
                    clss = run_query("SELECT * FROM fn_pobierz_klasy()")
                    if not clss.empty:
                        copt = {f"{r['nazwa_klasy']}": r['id_klasy'] for i, r in clss.iterrows()}
                        sc = st.selectbox("Klasa", list(copt.keys()))
                        c1, c2 = st.columns(2)
                        ma = c1.text_input("Marka")
                        mo = c2.text_input("Model")
                        ro = c1.number_input("Rok", 2000, 2030, 2023)
                        nr = c2.text_input("Rejestracja")
                        km = c1.number_input("Przebieg", 0)
                        stt = c2.text_input("Stan", "Sprawny")
                        if st.form_submit_button("Dodaj"):
                            ok, m = add_vehicle(copt[sc], ma, mo, ro, nr, km, stt, "Dostępny")
                            if ok:
                                st.success("Dodano")
                                time.sleep(1)
                                st.rerun()
                            else:
                                st.error(m)
            with mt2:
                if not all_cars.empty:
                    tod = st.selectbox("Usuń auto", list(opts.keys()), key="del_c")
                    if st.button("Usuń trwale"):
                        ok, m = delete_vehicle(opts[tod])
                        if ok:
                            st.success("Usunięto")
                            time.sleep(1)
                            st.rerun()
                        else:
                            st.error(m)
            with mt3:
                with st.form("serv_f"):
                    scs = st.selectbox("Auto", list(opts.keys()), key="srv_c")
                    dt = st.date_input("Data", datetime.date.today())
                    cost = st.number_input("Koszt", 0.0)
                    desc = st.text_input("Opis")
                    done = st.checkbox("Naprawa zakończona? (Zmień na 'Sprawny')")
                    if st.form_submit_button("Rejestruj"):
                        ok, m = add_service_entry(opts[scs], dt, desc, cost, 0)  # Przebieg update w update_status
                        if ok:
                            if done:
                                update_vehicle_status(opts[scs], int(
                                    all_cars[all_cars['id_pojazdu'] == opts[scs]].iloc[0]['przebieg']), "Sprawny",
                                                      "Dostępny")
                            st.success("Dodano wpis")
                            time.sleep(1)
                            st.rerun()
                        else:
                            st.error(m)

    with tab_analysis:
        st.subheader("📊 Analizy")
        fraza = st.text_input("Szukaj pojazdu (marka/rej)")
        if fraza:
            rs = run_query("SELECT * FROM SzukajPojazdu(%s)", (fraza,))
            st.dataframe(rs)

# ----------------- KLIENCI (NOWA, ROZBUDOWANA ZAKŁADKA) -----------------
elif menu == "👥 Klienci":
    st.title("👥 Zarządzanie Klientami")

    tab_list, tab_add, tab_manage, tab_crm = st.tabs(
        ["📂 Przeglądaj", "➕ Dodaj Nowego", "✏️ Zarządzaj (Edytuj/Usuń)", "🏆 CRM"])

    # 1. PRZEGLĄDANIE
    with tab_list:
        st.subheader("Lista Klientów")
        search_q = st.text_input("🔍 Filtruj (Nazwisko/PESEL):")
        try:
            df_cli = run_query("SELECT * FROM fn_pobierz_klientow()")
            if not df_cli.empty:
                if search_q:
                    df_cli = df_cli[df_cli.apply(lambda row: search_q.lower() in str(row).lower(), axis=1)]
                st.dataframe(df_cli, use_container_width=True)
            else:
                st.info("Brak klientów w bazie.")

            st.markdown("---")
            st.caption("Pobierz historię wypożyczeń klienta")
            cid_hist = st.number_input("ID Klienta", min_value=1, step=1)
            if st.button("Pobierz JSON Historii"):
                h = run_query("SELECT PobierzHistorieKlientaJSON(%s) as j", (cid_hist,))
                if not h.empty and h.iloc[0]['j']:
                    st.json(h.iloc[0]['j'])
        except Exception as e:
            st.error(f"Błąd: {e}")

    # 2. DODAWANIE
    with tab_add:
        st.subheader("Rejestracja Nowego Klienta")
        with st.form("add_client_form"):
            c1, c2 = st.columns(2)
            i = c1.text_input("Imię")
            n = c2.text_input("Nazwisko")
            p = c1.text_input("PESEL (11 cyfr)", max_chars=11)
            pj = c2.text_input("Nr Prawa Jazdy")
            t = c1.text_input("Telefon")
            e = c2.text_input("Email")
            a = st.text_area("Adres Zamieszkania")

            if st.form_submit_button("✅ Dodaj Klienta"):
                if i and n and p and pj:
                    ok, msg, new_id = add_new_client(i, n, p, pj, t, e, a)
                    if ok:
                        st.success(f"Klient dodany! ID: {new_id}")
                        time.sleep(1)
                        st.rerun()
                    else:
                        st.error(msg)
                else:
                    st.warning("Wymagane pola: Imię, Nazwisko, PESEL, Prawo Jazdy.")

    # 3. ZARZĄDZANIE (EDYCJA / USUWANIE)
    with tab_manage:
        st.subheader("Edycja i Usuwanie")
        try:
            df_cli_m = run_query("SELECT * FROM fn_pobierz_klientow()")
        except:
            df_cli_m = pd.DataFrame()

        if not df_cli_m.empty:
            opts_c = {f"{r['nazwisko']} {r['imie']} (ID: {r['id_klienta']})": r['id_klienta'] for _, r in
                      df_cli_m.iterrows()}
            selected_c_label = st.selectbox("Wybierz klienta do edycji/usunięcia:", list(opts_c.keys()))

            if selected_c_label:
                sel_id = opts_c[selected_c_label]
                curr_c = df_cli_m[df_cli_m['id_klienta'] == sel_id].iloc[0]

                st.markdown("---")
                col_edit, col_del = st.columns([2, 1])

                with col_edit:
                    st.markdown("#### ✏️ Edytuj Dane")
                    with st.form("edit_client_form"):
                        ei = st.text_input("Imię", value=curr_c["imie"])
                        en = st.text_input("Nazwisko", value=curr_c["nazwisko"])
                        ep = st.text_input("PESEL", value=curr_c["pesel"])
                        epj = st.text_input("Prawo Jazdy", value=curr_c["nr_prawa_jazdy"])
                        et = st.text_input("Telefon", value=curr_c["telefon"] if curr_c["telefon"] else "")
                        ee = st.text_input("Email", value=curr_c["email"] if curr_c["email"] else "")
                        ea = st.text_area("Adres", value=curr_c["adres"] if curr_c["adres"] else "")

                        if st.form_submit_button("💾 Zapisz Zmiany"):
                            ok, msg = update_client(int(sel_id), ei, en, ep, epj, et, ee, ea)
                            if ok:
                                st.success("Dane zaktualizowane!")
                                time.sleep(1)
                                st.rerun()
                            else:
                                st.error(msg)

                with col_del:
                    st.markdown("#### 🗑️ Usuń Klienta")
                    st.warning("Uwaga: Usunięcie jest możliwe tylko, jeśli klient nie ma historii wypożyczeń.")
                    if st.button("Usuń trwale z bazy", type="primary"):
                        ok, msg = delete_client(int(sel_id))
                        if ok:
                            st.success("Klient usunięty.")
                            time.sleep(1)
                            st.rerun()
                        else:
                            st.error(msg)
        else:
            st.info("Brak klientów do zarządzania.")

    # 4. CRM
    with tab_crm:
        c1, c2 = st.columns(2)
        with c1:
            st.markdown("#### Statusy")
            try:
                st.dataframe(run_query("SELECT * FROM StatusKlientow()"), hide_index=True)
            except Exception as e:
                st.error(str(e))
        with c2:
            st.markdown("#### Ranking VIP")
            try:
                st.dataframe(run_query("SELECT * FROM RankingKlientowVIP(5)"), hide_index=True)
            except Exception as e:
                st.error(str(e))

# ----------------- FINANSE -----------------
elif menu == "💰 Finanse":
    st.title("💰 Raporty Finansowe")
    rok = st.selectbox("Rok", [2023, 2024, 2025, 2026], index=3)
    try:
        df_fin = run_query("SELECT * FROM RaportPrzychodow(%s)", (rok,))
        if not df_fin.empty:
            c1, c2 = st.columns([1, 2])
            c1.dataframe(df_fin[["miesiac", "razem", "narastajaco"]], use_container_width=True)
            c2.bar_chart(df_fin.set_index("miesiac")["razem"])
        else:
            st.warning("Brak danych.")
    except Exception as e:
        st.error(f"Błąd: {e}")

# ----------------- PRACOWNICY -----------------
elif menu == "💼 Pracownicy (Admin)":
    st.title("💼 Zarządzanie Personelem")
    t1, t2 = st.tabs(["Efektywność", "Konta (Edycja / Dodawanie / Usuwanie)"])

    with t1:
        st.info("Ranking sprzedaży pracowników (kto ile zarobił dla firmy)")
        try:
            hr = run_query("SELECT * FROM EfektywnoscPracownikow()")
            st.dataframe(hr, use_container_width=True)
            if not hr.empty:
                st.bar_chart(hr.set_index("pracownik")["obrót"])
        except Exception as e:
            st.error(str(e))

    with t2:
        try:
            # Pobieramy listę pracowników
            staff = run_query("SELECT * FROM fn_pobierz_pracownikow()")
        except:
            staff = pd.DataFrame()

        # --- 1. LISTA PRACOWNIKÓW I USUWANIE ---
        st.markdown("### 1. Lista Pracowników")
        if not staff.empty:
            for _, r in staff.iterrows():
                # Wyświetlamy w ładnych kolumnach
                c1, c2, c3 = st.columns([3, 2, 1])
                with c1:
                    st.write(f"**{r['imie']} {r['nazwisko']}**")
                    st.caption(f"Stanowisko: {r['stanowisko']}")
                with c2:
                    st.write(f"Login: `{r['login']}`")
                with c3:
                    # Blokada usuwania samego siebie i admina
                    if str(r['id_pracownika']) != str(user_id) and r['login'] != 'admin':
                        if st.button("🗑️ Usuń", key=f"del_st_{r['id_pracownika']}"):
                            delete_employee(r['id_pracownika'])
                            st.success("Usunięto.")
                            time.sleep(0.5)
                            st.rerun()
                    else:
                        st.write("🔒")
            st.markdown("---")
        else:
            st.warning("Brak pracowników w bazie.")

        # --- 2. EDYCJA I DODAWANIE (Dwie kolumny) ---
        col_edit, col_add = st.columns(2)

        # LEWA KOLUMNA: EDYCJA
        with col_edit:
            st.subheader("✏️ Edytuj Dane")
            with st.container(border=True):
                if not staff.empty:
                    # Tworzymy listę do wyboru: "Kowalski Jan (Sprzedawca)" -> ID
                    opts_emp = {f"{r['nazwisko']} {r['imie']} ({r['stanowisko']})": r['id_pracownika'] for _, r in
                                staff.iterrows()}
                    sel_emp_label = st.selectbox("Wybierz pracownika do zmiany:", list(opts_emp.keys()))

                    if sel_emp_label:
                        emp_id_edit = opts_emp[sel_emp_label]
                        # Pobieramy aktualne dane wybranego pracownika
                        curr_emp = staff[staff['id_pracownika'] == emp_id_edit].iloc[0]

                        with st.form("edit_emp_form"):
                            new_imie = st.text_input("Imię", value=curr_emp['imie'])
                            new_nazwisko = st.text_input("Nazwisko", value=curr_emp['nazwisko'])
                            # Ustawiamy index selectboxa na obecne stanowisko
                            stanowiska = ["Sprzedawca", "Serwisant", "Menadżer"]
                            try:
                                curr_idx = stanowiska.index(curr_emp['stanowisko'])
                            except ValueError:
                                curr_idx = 0
                            new_stanowisko = st.selectbox("Stanowisko", stanowiska, index=curr_idx)

                            st.caption("Loginu i hasła nie można zmienić w tym panelu.")

                            if st.form_submit_button("💾 Zapisz zmiany"):
                                ok, msg = update_employee(int(emp_id_edit), new_imie, new_nazwisko, new_stanowisko)
                                if ok:
                                    st.success("Zaktualizowano dane pracownika!")
                                    time.sleep(1)
                                    st.rerun()
                                else:
                                    st.error(msg)
                else:
                    st.info("Brak pracowników do edycji.")

        # PRAWA KOLUMNA: DODAWANIE
        with col_add:
            st.subheader("➕ Dodaj Nowego")
            with st.container(border=True):
                with st.form("new_emp_form"):
                    ei = st.text_input("Imię")
                    en = st.text_input("Nazwisko")
                    es = st.selectbox("Stanowisko", ["Sprzedawca", "Serwisant", "Menadżer"])
                    el = st.text_input("Login")
                    ep = st.text_input("Hasło", type="password")

                    if st.form_submit_button("✅ Utwórz konto"):
                        if ei and en and el and ep:
                            ok, m = add_employee(ei, en, es, el, ep)
                            if ok:
                                st.success("Pracownik dodany!")
                                time.sleep(1)
                                st.rerun()
                            else:
                                st.error(m)
                        else:
                            st.warning("Uzupełnij wszystkie pola.")
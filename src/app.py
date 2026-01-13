import streamlit as st
import pandas as pd
from db import run_query, run_command, check_login
import datetime
import time
from fpdf import FPDF

st.set_page_config(page_title="System Wypożyczalni", layout="wide", initial_sidebar_state="expanded")

# --- CSS (Wygląd + Ramka Logowania) ---
st.markdown("""
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
""", unsafe_allow_html=True)


# --- FUNKCJE POMOCNICZE (CRUD Z OBSŁUGĄ WYJĄTKÓW) ---
def get_client_id_by_pesel(pesel):
    try:
        res = run_query("SELECT id_klienta FROM Klienci WHERE pesel = %s", (pesel,))
        if not res.empty: return res.iloc[0]['id_klienta']
        return None
    except Exception:
        return None


def add_new_client_fast(imie, nazwisko, pesel, nr_prawa, telefon, email, adres):
    try:
        sql = "CALL sp_dodaj_klienta(%s, %s, %s, %s, %s, %s, %s);"
        success, msg = run_command(sql, (imie, nazwisko, pesel, nr_prawa, telefon, email, adres))
        if not success: return False, msg, None
        new_id = get_client_id_by_pesel(pesel)
        return True, "Dodano klienta.", new_id
    except Exception as e:
        return False, f"Błąd krytyczny (Klient): {str(e)}", None


# Funkcja czyszcząca polskie znaki dla PDF
def clean_text(text):
    if not isinstance(text, str):
        text = str(text)
    replacements = {
        'ą': 'a', 'ć': 'c', 'ę': 'e', 'ł': 'l', 'ń': 'n', 'ó': 'o', 'ś': 's', 'ź': 'z', 'ż': 'z',
        'Ą': 'A', 'Ć': 'C', 'Ę': 'E', 'Ł': 'L', 'Ń': 'N', 'Ó': 'O', 'Ś': 'S', 'Ź': 'Z', 'Ż': 'Z'
    }
    for k, v in replacements.items():
        text = text.replace(k, v)
    return text


# Generowanie PDF
def create_pdf_confirmation(klient_info, auto_info, data_od, data_do, cena, pracownik):
    try:
        pdf = FPDF()
        pdf.add_page()

        pdf.set_font("Arial", 'B', 16)
        pdf.cell(0, 10, clean_text("Potwierdzenie Rezerwacji"), ln=True, align='C')
        pdf.ln(10)

        pdf.set_font("Arial", '', 12)
        pdf.cell(0, 10, clean_text(f"Data wystawienia: {datetime.date.today()}"), ln=True)
        pdf.cell(0, 10, clean_text(f"Obslugujacy: {pracownik}"), ln=True)
        pdf.ln(5)

        pdf.set_font("Arial", 'B', 12)
        pdf.cell(0, 10, clean_text("DANE KLIENTA:"), ln=True)
        pdf.set_font("Arial", '', 12)
        pdf.cell(0, 10, clean_text(f"Klient: {klient_info}"), ln=True)
        pdf.ln(5)

        pdf.set_font("Arial", 'B', 12)
        pdf.cell(0, 10, clean_text("DANE POJAZDU:"), ln=True)
        pdf.set_font("Arial", '', 12)
        pdf.cell(0, 10, clean_text(f"Pojazd: {auto_info['marka']} {auto_info['model']}"), ln=True)
        pdf.cell(0, 10, clean_text(f"Nr Rejestracyjny: {auto_info['nr_rej']}"), ln=True)
        pdf.ln(5)

        pdf.set_font("Arial", 'B', 12)
        pdf.cell(0, 10, clean_text("SZCZEGOLY WYNAJMU:"), ln=True)
        pdf.set_font("Arial", '', 12)
        pdf.cell(0, 10, clean_text(f"Od: {data_od}  Do: {data_do}"), ln=True)
        pdf.cell(0, 10, clean_text(f"Laczna kwota: {cena:.2f} PLN"), ln=True)

        pdf.ln(20)
        pdf.set_font("Arial", 'I', 10)
        pdf.cell(0, 10, clean_text("Dziekujemy za skorzystanie z uslug Rent-A-Car OS"), align='C')

        return bytes(pdf.output())
    except Exception as e:
        print(f"Błąd PDF: {e}")
        return b""


# ZARZĄDZANIE PRACOWNIKAMI
def add_employee(imie, nazwisko, stanowisko, login, haslo):
    try:
        sql = "CALL sp_dodaj_pracownika(%s, %s, %s, %s, %s);"
        return run_command(sql, (imie, nazwisko, stanowisko, login, haslo))
    except Exception as e:
        return False, f"Wyjątek (Dodaj Pracownika): {str(e)}"


def update_employee(emp_id, imie, nazwisko, stanowisko):
    try:
        sql = "CALL sp_aktualizuj_pracownika(%s, %s, %s, %s);"
        return run_command(sql, (emp_id, imie, nazwisko, stanowisko))
    except Exception as e:
        return False, f"Wyjątek (Edytuj Pracownika): {str(e)}"


def delete_employee(emp_id):
    try:
        sql = "CALL sp_usun_pracownika(%s);"
        return run_command(sql, (emp_id,))
    except Exception as e:
        return False, f"Wyjątek (Usuń Pracownika): {str(e)}"


# ZARZĄDZANIE POJAZDAMI
def add_vehicle(id_klasy, marka, model, rok, nr_rej, przebieg, stan, status):
    try:
        sql = "CALL sp_dodaj_pojazd(%s, %s, %s, %s, %s, %s, %s, %s);"
        return run_command(sql, (id_klasy, marka, model, rok, nr_rej, przebieg, stan, status))
    except Exception as e:
        return False, f"Wyjątek (Dodaj Pojazd): {str(e)}"


def update_vehicle_status(id_pojazdu, przebieg, stan, status):
    try:
        sql = "CALL sp_aktualizuj_pojazd(%s, NULL, NULL, NULL, NULL, NULL, %s, %s, %s);"
        return run_command(sql, (id_pojazdu, przebieg, stan, status))
    except Exception as e:
        return False, f"Wyjątek (Aktualizuj Pojazd): {str(e)}"


def delete_vehicle(id_pojazdu):
    try:
        sql = "CALL sp_usun_pojazd(%s);"
        return run_command(sql, (id_pojazdu,))
    except Exception as e:
        return False, f"Wyjątek (Usuń Pojazd): {str(e)}"


# NOWA FUNKCJA: DODAWANIE SERWISU
def add_service_entry(id_pojazdu, data, opis, koszt, przebieg):
    try:
        # sp_dodaj_serwis(id_pojazdu, data, opis, koszt, przebieg)
        sql = "CALL sp_dodaj_serwis(%s, %s, %s, %s, %s);"
        return run_command(sql, (id_pojazdu, data, opis, koszt, przebieg))
    except Exception as e:
        return False, f"Wyjątek (Dodaj Serwis): {str(e)}"


# --- LOGIKA SESJI (PAMIĘĆ) ---
if 'logged_in' not in st.session_state: st.session_state['logged_in'] = False
if 'user_info' not in st.session_state: st.session_state['user_info'] = {}

if 'reservation_step' not in st.session_state: st.session_state['reservation_step'] = None
if 'selected_car_data' not in st.session_state: st.session_state['selected_car_data'] = None
if 'last_reservation_data' not in st.session_state: st.session_state['last_reservation_data'] = None

# ================= EKRAN LOGOWANIA =================
if not st.session_state['logged_in']:
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
                        st.session_state['logged_in'] = True
                        st.session_state['user_info'] = user_data
                        st.success(f"Witaj, {user_data['imie']}!")
                        st.rerun()
                    else:
                        st.error("Błędny login lub hasło.")
                except Exception as e:
                    st.error(f"Błąd połączenia z bazą: {e}")
    st.stop()

# ================= GŁÓWNA APLIKACJA  =================
user_id = st.session_state['user_info']['id_pracownika']
user_name = st.session_state['user_info']['imie']
user_role = st.session_state['user_info']['stanowisko']

with st.sidebar:
    st.title("🚗 Rent-A-Car OS")
    st.success(f"👤 {user_name} ({user_role})")

    menu_options = ["🏠 Pulpit", "🚗 Flota & Rezerwacje", "👥 Klienci", "💰 Finanse"]
    if user_role == 'Menadżer':
        menu_options.append("💼 Pracownicy (Admin)")

    menu = st.radio("Sekcje", menu_options)
    st.markdown("---")

    c_logout, c_reset = st.columns(2)
    if c_logout.button("Wyloguj"):
        st.session_state.clear()
        st.rerun()
    if c_reset.button("Reset"):
        st.session_state['reservation_step'] = None
        st.rerun()

# ----------------- PULPIT -----------------
if menu == "🏠 Pulpit":
    st.title("🏠 Pulpit Menadżera")
    c1, c2, c3, c4 = st.columns(4)
    try:
        count_cars = run_query("SELECT COUNT(*) as c FROM Pojazdy").iloc[0]['c']
        count_clients = run_query("SELECT COUNT(*) as c FROM Klienci").iloc[0]['c']
        count_reservations = \
            run_query("SELECT COUNT(*) as c FROM Rezerwacje WHERE Status_Rezerwacji = 'Potwierdzona'").iloc[0]['c']
    except:
        count_cars, count_clients, count_reservations = 0, 0, 0

    c1.metric("Wszystkie Pojazdy", count_cars)
    c2.metric("Baza Klientów", count_clients)
    c3.metric("Aktywne Wynajmy", count_reservations)
    c4.metric("Dostępne teraz", int(count_cars) - int(count_reservations))

    st.markdown("---")

    # [ALGORYTM 1] OblozenieMiesieczne
    col_chart, col_alerts = st.columns([2, 1])

    with col_chart:
        st.subheader("📊 Obłożenie w bieżącym miesiącu")
        try:
            now = datetime.date.today()
            df_chart = run_query("SELECT * FROM OblozenieMiesieczne(%s, %s)", (now.year, now.month))
            if not df_chart.empty:
                st.area_chart(df_chart.set_index("dzien")['liczba_aut'])
            else:
                st.info("Brak danych na ten miesiąc.")
        except Exception as e:
            st.error(f"Błąd ładowania wykresu: {e}")

    # [ALGORYTM 2] PrognozaSerwisowa (NOWOŚĆ)
    with col_alerts:
        st.subheader("⚠️ Alerty Serwisowe")
        try:
            df_serv = run_query("SELECT * FROM PrognozaSerwisowa(15000)")
            if not df_serv.empty:
                # Filtrujemy tylko te co wymagają uwagi
                urgent = df_serv[df_serv['status'] != '✅ OK']
                if not urgent.empty:
                    st.error(f"Pojazdy wymagające uwagi: {len(urgent)}")
                    st.dataframe(urgent[['pojazd', 'km_do_serwisu', 'status']], use_container_width=True,
                                 hide_index=True)
                else:
                    st.success("Wszystkie pojazdy są w dobrym stanie.")
        except Exception as e:
            st.error(f"Błąd prognozy: {e}")

# ----------------- FLOTA -----------------
elif menu == "🚗 Flota & Rezerwacje":
    st.title("🚗 Flota i Rezerwacje")

    # 3 ZAKŁADKI
    tab_rez, tab_fleet, tab_analysis = st.tabs(
        ["🔍 Wyszukiwanie i Rezerwacja", "🛠️ Zarządzanie Flotą", "📊 Analizy i Szukanie"])

    # === ZAKŁADKA 1: REZERWACJE ===
    with tab_rez:
        if st.session_state['reservation_step'] is None:
            with st.container(border=True):
                st.subheader("1. Znajdź samochód")
                c1, c2, c3 = st.columns([2, 2, 1])
                d_od = c1.date_input("Data Odbioru", datetime.date.today())
                d_do = c2.date_input("Data Zwrotu", datetime.date.today() + datetime.timedelta(days=3))
                st.session_state['dates'] = (d_od, d_do)
                # [ALGORYTM 3] ZnajdzDostepnePojazdy (Teraz blokuje zepsute auta!)
                if c3.button("🔍 Szukaj Wolnych Aut", type="primary", use_container_width=True):
                    st.session_state['search_performed'] = True

            if st.session_state.get('search_performed'):
                try:
                    df_auta = run_query("SELECT * FROM ZnajdzDostepnePojazdy(%s, %s, NULL)", (d_od, d_do))
                    if df_auta.empty:
                        st.warning("Brak dostępnych aut w tym terminie (lub auta wymagają serwisu).")
                    else:
                        st.success(f"Dostępne pojazdy: {len(df_auta)}")
                        cols = st.columns(2)
                        for idx, row in df_auta.iterrows():
                            with cols[idx % 2]:
                                with st.container(border=True):
                                    c_txt, c_act = st.columns([3, 1])
                                    with c_txt:
                                        st.markdown(f"### {row['marka']} {row['model']}")
                                        st.caption(f"Klasa: {row['klasa']} | Rej: {row['nr_rej']}")
                                        days = (d_do - d_od).days
                                        if days < 1: days = 1
                                        total = days * row['cena']
                                        st.write(f"**{row['cena']} PLN / doba** | Razem: **{total:.2f} PLN**")
                                    with c_act:
                                        if st.button("Rezerwuj", key=f"btn_{row['id_pojazdu']}"):
                                            st.session_state['reservation_step'] = 'form'
                                            st.session_state['selected_car_data'] = row
                                            st.rerun()
                except Exception as e:
                    st.error(f"Błąd wyszukiwania: {e}")

        elif st.session_state['reservation_step'] == 'form' and st.session_state['selected_car_data'] is not None:
            car = st.session_state['selected_car_data']
            d_start, d_end = st.session_state['dates']
            days = (d_end - d_start).days
            if days < 1: days = 1
            price_total = days * car['cena']

            st.markdown("---")
            st.markdown(f"""
            <div class="reservation-box">
                <h3>📝 Finalizacja Rezerwacji: {car['marka']} {car['model']}</h3>
                <p>Termin: <b>{d_start}</b> do <b>{d_end}</b> ({days} dni)</p>
                <p style="font-size: 20px">Do zapłaty: <b>{price_total:.2f} PLN</b></p>
                <p>Obsługujący: <b>{user_name}</b></p>
            </div>""", unsafe_allow_html=True)
            st.write("")

            method = st.radio("Klient:", ["👤 Wybierz z bazy", "➕ Dodaj nowego klienta"], horizontal=True)
            selected_client_id = None
            client_name_str = ""

            with st.form("final_booking"):
                if method == "👤 Wybierz z bazy":
                    try:
                        clients_df = run_query(
                            "SELECT id_klienta, imie, nazwisko, pesel FROM Klienci ORDER BY Nazwisko")
                        if not clients_df.empty:
                            options = {f"{r['nazwisko']} {r['imie']} ({r['pesel']})": r['id_klienta'] for i, r in
                                       clients_df.iterrows()}
                            chosen = st.selectbox("Szukaj klienta:", list(options.keys()))
                            if chosen:
                                selected_client_id = options[chosen]
                                client_name_str = chosen.split('(')[0]
                        else:
                            st.warning("Brak klientów w bazie.")
                    except Exception as e:
                        st.error(f"Błąd pobierania klientów: {e}")
                else:
                    c1, c2 = st.columns(2)
                    ni = c1.text_input("Imię");
                    nn = c2.text_input("Nazwisko")
                    np = c1.text_input("PESEL", max_chars=11);
                    npr = c2.text_input("Prawo Jazdy")
                    nt = c1.text_input("Telefon");
                    ne = c2.text_input("Email");
                    na = st.text_area("Adres")
                    client_name_str = f"{nn} {ni}"

                miejsce = st.text_input("Miejsce odbioru", "Siedziba Główna")

                if st.form_submit_button("✅ Potwierdź i Zarezerwuj", type="primary"):
                    if method == "➕ Dodaj nowego klienta":
                        if not (ni and nn and np): st.error("Brak danych osobowych!"); st.stop()
                        ok, msg, new_id = add_new_client_fast(ni, nn, np, npr, nt, ne, na)
                        if not ok: st.error(msg); st.stop()
                        selected_client_id = new_id

                    cur_date = datetime.date.today()
                    try:
                        res_ok, res_msg = run_command("CALL sp_dodaj_rezerwacje(%s, %s, %s, %s, %s, %s, %s, %s, %s);",
                                                      (selected_client_id, int(car['id_pojazdu']), user_id, cur_date,
                                                       d_start,
                                                       d_end, miejsce, float(price_total), 'Potwierdzona'))
                        if res_ok:
                            st.session_state['reservation_step'] = 'success'
                            st.session_state['last_reservation_data'] = {
                                'car': car, 'client_name': client_name_str,
                                'd_start': d_start, 'd_end': d_end,
                                'price': price_total, 'worker': user_name
                            }
                            st.rerun()
                        else:
                            st.error(f"Błąd bazy danych: {res_msg}")
                    except Exception as e:
                        st.error(f"Błąd krytyczny rezerwacji: {e}")

            if st.button("❌ Anuluj"):
                st.session_state['reservation_step'] = None;
                st.rerun()

        elif st.session_state['reservation_step'] == 'success':
            st.balloons()
            st.title("✅ Rezerwacja zakończona sukcesem!")

            data = st.session_state['last_reservation_data']
            if data:
                st.success(
                    f"Zarezerwowano pojazd: {data['car']['marka']} {data['car']['model']} dla klienta: {data['client_name']}")

                pdf_bytes = create_pdf_confirmation(
                    klient_info=data['client_name'],
                    auto_info=data['car'],
                    data_od=data['d_start'],
                    data_do=data['d_end'],
                    cena=data['price'],
                    pracownik=data['worker']
                )

                c1, c2 = st.columns(2)
                with c1:
                    if pdf_bytes:
                        st.download_button(
                            label="📄 POBIERZ POTWIERDZENIE (PDF)",
                            data=pdf_bytes,
                            file_name=f"Rezerwacja_{data['car']['nr_rej']}_{data['d_start']}.pdf",
                            mime='application/pdf',
                            type='primary'
                        )
                    else:
                        st.warning("Nie udało się wygenerować PDF.")
                with c2:
                    if st.button("🏠 Wróć do menu głównego"):
                        st.session_state['reservation_step'] = None
                        st.session_state['selected_car_data'] = None
                        st.session_state['search_performed'] = False
                        st.session_state['last_reservation_data'] = None
                        st.rerun()

    # === ZAKŁADKA 2: ZARZĄDZANIE FLOTĄ ===
    with tab_fleet:
        st.subheader("🛠️ Zarządzanie Flotą")
        try:
            all_cars = run_query("SELECT * FROM Pojazdy ORDER BY ID_Pojazdu")
        except Exception:
            all_cars = pd.DataFrame()

        with st.container(border=True):
            st.markdown("#### 🔧 Aktualizacja Stanu Technicznego")

            if not all_cars.empty:
                car_opts = {
                    f"#{r['id_pojazdu']} {r['marka']} {r['model']} ({r['numer_rejestracyjny']})": r['id_pojazdu'] for
                    i, r in all_cars.iterrows()}
                selected_car_label = st.selectbox("Wybierz pojazd do edycji", list(car_opts.keys()))

                if selected_car_label:
                    selected_car_id = car_opts[selected_car_label]
                    curr_car = all_cars[all_cars['id_pojazdu'] == selected_car_id].iloc[0]

                    with st.form("update_status_form"):
                        c1, c2, c3 = st.columns(3)
                        new_status = c1.selectbox("Status dostępności", ["Dostępny", "W serwisie", "Wypożyczony"],
                                                  index=["Dostępny", "W serwisie", "Wypożyczony"].index(
                                                      curr_car['status_dostepnosci']))
                        new_przebieg = c2.number_input("Aktualny przebieg", value=int(curr_car['przebieg']), step=100)
                        new_stan = c3.text_input("Stan Techniczny / Uwagi", value=curr_car['stan_techniczny'])

                        if st.form_submit_button("💾 Zapisz zmiany stanu"):
                            ok, msg = update_vehicle_status(int(selected_car_id), int(new_przebieg), new_stan,
                                                            new_status)
                            if ok:
                                st.success("Zaktualizowano stan pojazdu!");
                                time.sleep(1);
                                st.rerun()
                            else:
                                st.error(f"Błąd: {msg}")
            else:
                st.warning("Brak pojazdów w bazie.")

        st.markdown("---")
        if user_role == 'Menadżer':
            st.markdown("#### ⚡ Strefa Menadżera")

            man_tab1, man_tab2, man_tab3 = st.tabs(
                ["➕ Dodaj Pojazd", "🗑️ Usuń Pojazd", "🔧 Rejestracja Serwisu / Usterki"])

            # --- DODAWANIE AUTA ---
            with man_tab1:
                with st.form("add_car_form"):
                    try:
                        classes_df = run_query("SELECT * FROM Klasy_Pojazdow")
                    except:
                        classes_df = pd.DataFrame()

                    if not classes_df.empty:
                        class_opts_c = {f"{r['nazwa_klasy']} ({r['cena_za_dobe']} PLN)": r['id_klasy'] for i, r in
                                        classes_df.iterrows()}
                        sel_class_label = st.selectbox("Klasa Pojazdu", list(class_opts_c.keys()))
                        sel_class_id = class_opts_c[sel_class_label]

                        c1, c2 = st.columns(2)
                        n_marka = c1.text_input("Marka")
                        n_model = c2.text_input("Model")
                        n_rok = c1.number_input("Rok produkcji", min_value=2000, max_value=2030, value=2023)
                        n_rej = c2.text_input("Nr Rejestracyjny")
                        n_przebieg = c1.number_input("Przebieg początkowy", value=0)
                        n_stan = c2.text_input("Stan techniczny", value="Sprawny")
                        n_status = st.selectbox("Status początkowy", ["Dostępny", "W serwisie"])

                        if st.form_submit_button("Dodaj do floty"):
                            if n_marka and n_model and n_rej:
                                ok, msg = add_vehicle(sel_class_id, n_marka, n_model, n_rok, n_rej, n_przebieg, n_stan,
                                                      n_status)
                                if ok:
                                    st.success("Pojazd dodany!"); time.sleep(1); st.rerun()
                                else:
                                    st.error(f"Błąd: {msg}")
                            else:
                                st.warning("Uzupełnij wymagane pola (Marka, Model, Rejestracja).")
                    else:
                        st.error("Brak klas pojazdów w bazie! Najpierw dodaj klasy.")

            # --- USUWANIE AUTA ---
            with man_tab2:
                if not all_cars.empty:
                    del_car_label = st.selectbox("Wybierz pojazd do usunięcia", list(car_opts.keys()), key="del_select")
                    if st.button("🗑️ Usuń wybrany pojazd", type="primary"):
                        del_id = car_opts[del_car_label]
                        ok, msg = delete_vehicle(del_id)
                        if ok:
                            st.success("Pojazd usunięty z bazy.");
                            time.sleep(1);
                            st.rerun()
                        else:
                            st.error(f"Błąd: {msg}")

            # --- DODAWANIE SERWISU (RESET LICZNIKA) ---
            with man_tab3:
                st.info("Dodanie wpisu serwisowego resetuje licznik 'Km do serwisu' w algorytmie prognozowania.")
                with st.form("service_form"):
                    # Wybór auta (jeśli lista niepusta)
                    if not all_cars.empty:
                        s_car_label = st.selectbox("Pojazd w serwisie", list(car_opts.keys()), key="serv_select")
                        s_id = car_opts[s_car_label]
                        # Pobieramy aktualny przebieg, żeby podpowiedzieć
                        current_km = all_cars[all_cars['id_pojazdu'] == s_id].iloc[0]['przebieg']
                    else:
                        s_id = None
                        current_km = 0

                    c1, c2 = st.columns(2)
                    s_data = c1.date_input("Data Serwisu", datetime.date.today())
                    s_koszt = c2.number_input("Koszt (PLN)", value=0.0, step=10.0)

                    s_typ = st.selectbox("Rodzaj zgłoszenia", [
                        "Przegląd okresowy (Olej/Filtry) - RESET LICZNIKA",
                        "Wymiana Opon",
                        "Usterka Mechaniczna",
                        "Uszkodzenie Wizualne",
                        "Naprawa Blacharska",
                        "Inne"
                    ])

                    s_opis_text = st.text_area("Dodatkowy opis usterki / prac")
                    s_przebieg = st.number_input("Przebieg w chwili serwisu", value=int(current_km), step=100)

                    # Łączymy typ z opisem dla bazy
                    full_opis = f"[{s_typ}] {s_opis_text}"

                    if st.form_submit_button("✅ Zarejestruj Serwis / Naprawę"):
                        if s_id:
                            ok, msg = add_service_entry(int(s_id), s_data, full_opis, float(s_koszt), int(s_przebieg))
                            if ok:
                                st.success("Serwis dodany! Auto jest teraz 'czyste' w systemie prognoz.")
                                time.sleep(2)
                                st.rerun()
                            else:
                                st.error(f"Błąd: {msg}")
                        else:
                            st.error("Brak pojazdu.")

        else:
            st.info("🔒 Funkcje dodawania i usuwania pojazdów są dostępne tylko dla Menadżera.")

    # === ZAKŁADKA 3: ANALIZY I SZUKANIE (NOWA) ===
    with tab_analysis:
        st.subheader("📊 Analizy Floty i Wyszukiwanie")
        col_s, col_a = st.columns(2)

        # [ALGORYTM 4] SzukajPojazdu
        with col_s:
            with st.container(border=True):
                st.markdown("#### 🔍 Szybkie Szukanie")
                fraza = st.text_input("Wpisz markę, model lub nr rejestracyjny:")
                if fraza:
                    try:
                        res_search = run_query("SELECT * FROM SzukajPojazdu(%s)", (fraza,))
                        if not res_search.empty:
                            st.dataframe(res_search[['marka', 'model', 'numer_rejestracyjny', 'status_dostepnosci']],
                                         hide_index=True)
                        else:
                            st.info("Nie znaleziono pojazdu.")
                    except Exception as e:
                        st.error(e)

        # [ALGORYTM 5] AnalizaPrzestojow
        with col_a:
            with st.container(border=True):
                st.markdown("#### 💤 Analiza Przestojów")
                dni = st.slider("Minimalna liczba dni przestoju:", 1, 30, 7)
                if st.button("Analizuj flotę"):
                    try:
                        df_idle = run_query("SELECT * FROM AnalizaPrzestojow(%s)", (dni,))
                        if not df_idle.empty:
                            st.dataframe(df_idle, hide_index=True)
                        else:
                            st.success("Brak długich przestojów w firmie!")
                    except Exception as e:
                        st.error(e)


# ----------------- KLIENCI -----------------
elif menu == "👥 Klienci":
    st.title("👥 Baza Klientów i CRM")

    # Podział na BAZĘ (stare) i CRM (nowe algorytmy)
    tab_base, tab_crm = st.tabs(["📂 Baza i Historia", "🏆 CRM i Raporty"])

    with tab_base:
        search = st.text_input("🔍 Szukaj klienta:", placeholder="Nazwisko...")
        try:
            df = run_query("SELECT * FROM fn_pobierz_klientow()")
            if search: df = df[df.apply(lambda x: search.lower() in str(x).lower(), axis=1)]
            st.dataframe(df, use_container_width=True)
        except Exception as e:
            st.error(f"Błąd pobierania klientów: {e}")

        # [ALGORYTM 6] PobierzHistorieKlientaJSON
        with st.expander("📜 Historia (Eksport JSON)"):
            cid = st.number_input("ID Klienta do pobrania historii", 1)
            if st.button("Pobierz JSON"):
                try:
                    res = run_query("SELECT PobierzHistorieKlientaJSON(%s) as j", (cid,))
                    if not res.empty and res.iloc[0]['j']: st.json(res.iloc[0]['j'])
                except Exception as e:
                    st.error(f"Błąd: {e}")

    with tab_crm:
        c1, c2 = st.columns(2)

        # [ALGORYTM 7] StatusKlientow
        with c1:
            st.markdown("#### 🏷️ Statusy Lojalnościowe")
            try:
                df_status = run_query("SELECT * FROM StatusKlientow()")
                st.dataframe(df_status, hide_index=True, use_container_width=True)
            except Exception as e:
                st.error(e)

        # [ALGORYTM 8] RankingKlientowVIP
        with c2:
            st.markdown("#### 💎 Ranking VIP (Top Spenders)")
            top_n = st.number_input("Ilu klientów pokazać?", 3, 20, 5)
            try:
                df_vip = run_query("SELECT * FROM RankingKlientowVIP(%s)", (top_n,))
                st.dataframe(df_vip, hide_index=True, use_container_width=True)
            except Exception as e:
                st.error(e)


# ----------------- FINANSE -----------------
elif menu == "💰 Finanse":
    st.title("💰 Raporty Finansowe")
    # [ALGORYTM 9] RaportPrzychodow
    rok = st.selectbox("Rok", [2023, 2024, 2025, 2026], index=3)
    try:
        df_fin = run_query("SELECT * FROM RaportPrzychodow(%s)", (rok,))
        if not df_fin.empty:
            c1, c2 = st.columns([1, 2])
            c1.dataframe(df_fin[['miesiac', 'razem', 'narastajaco']], use_container_width=True)
            c2.bar_chart(df_fin.set_index("miesiac")['razem'])
        else:
            st.warning("Brak danych.")
    except Exception as e:
        st.error(f"Błąd: {e}")


# ----------------- PRACOWNICY -----------------
elif menu == "💼 Pracownicy (Admin)":
    st.title("💼 Zarządzanie Personelem")

    tab1, tab2 = st.tabs(["📊 Efektywność (Raport)", "🛠️ Zarządzaj Kontami"])

    with tab1:
        st.info("Ranking sprzedaży pracowników (kto ile zarobił dla firmy)")
        # [ALGORYTM 10] EfektywnoscPracownikow
        try:
            df_hr = run_query("SELECT * FROM EfektywnoscPracownikow()")
            if not df_hr.empty:
                st.dataframe(df_hr, use_container_width=True)
                st.bar_chart(df_hr.set_index("pracownik")['obrót'])
        except Exception as e:
            st.error(f"Błąd raportu: {e}")

    with tab2:
        try:
            staff = run_query(
                "SELECT id_pracownika, imie, nazwisko, stanowisko, login FROM Pracownicy ORDER BY id_pracownika")
        except Exception:
            staff = pd.DataFrame()

        st.markdown("### 1. Lista i Usuwanie")
        st.info("Przeglądaj kadrę. Użyj ikony kosza, aby usunąć pracownika.")

        if not staff.empty:
            for i, row in staff.iterrows():
                c1, c2, c3, c4, c5 = st.columns([1, 2, 2, 2, 1])
                c1.write(f"#{row['id_pracownika']}")
                c2.write(f"**{row['imie']} {row['nazwisko']}**")
                c3.write(row['stanowisko'])
                c4.write(f"Login: `{row['login']}`")

                can_delete = True
                if row['login'] == 'admin' or row['id_pracownika'] == user_id:
                    can_delete = False

                if can_delete:
                    if c5.button("🗑️", key=f"del_emp_{row['id_pracownika']}"):
                        ok, msg = delete_employee(row['id_pracownika'])
                        if ok:
                            st.success("Pracownik usunięty.")
                            time.sleep(1)
                            st.rerun()
                        else:
                            st.error(f"Błąd: {msg}")
                else:
                    c5.write("🔒")
        else:
            st.warning("Brak pracowników (lub błąd połączenia).")

        st.markdown("---")

        col_edit, col_add = st.columns(2)

        with col_edit:
            st.markdown("### 2. ✏️ Edytuj Dane Pracownika")
            with st.container(border=True):
                if not staff.empty:
                    emp_opts = {f"{r['nazwisko']} {r['imie']} ({r['stanowisko']})": r['id_pracownika'] for i, r in
                                staff.iterrows()}
                    sel_emp_label = st.selectbox("Wybierz osobę do edycji:", list(emp_opts.keys()))

                    if sel_emp_label:
                        sel_emp_id = emp_opts[sel_emp_label]
                        curr_emp = staff[staff['id_pracownika'] == sel_emp_id].iloc[0]

                        with st.form("edit_employee_form"):
                            u_imie = st.text_input("Imię", value=curr_emp['imie'])
                            u_nazwisko = st.text_input("Nazwisko", value=curr_emp['nazwisko'])
                            u_stanowisko = st.selectbox("Stanowisko", ["Sprzedawca", "Serwisant", "Menadżer"],
                                                        index=["Sprzedawca", "Serwisant", "Menadżer"].index(
                                                            curr_emp['stanowisko'])
                                                        if curr_emp['stanowisko'] in ["Sprzedawca", "Serwisant",
                                                                                      "Menadżer"] else 0)

                            if st.form_submit_button("Zapisz Zmiany"):
                                ok, msg = update_employee(int(sel_emp_id), u_imie, u_nazwisko, u_stanowisko)
                                if ok:
                                    st.success("Dane zaktualizowane!");
                                    time.sleep(1);
                                    st.rerun()
                                else:
                                    st.error(f"Błąd: {msg}")

        with col_add:
            st.markdown("### 3. ➕ Dodaj Nowego")
            with st.container(border=True):
                with st.form("add_employee_form"):
                    e_imie = st.text_input("Imię")
                    e_nazwisko = st.text_input("Nazwisko")
                    e_stanowisko = st.selectbox("Stanowisko", ["Sprzedawca", "Serwisant", "Menadżer"])
                    e_login = st.text_input("Nowy Login")
                    e_haslo = st.text_input("Nowe Hasło", type="password")

                    if st.form_submit_button("Utwórz Konto"):
                        if e_imie and e_nazwisko and e_login and e_haslo:
                            ok, msg = add_employee(e_imie, e_nazwisko, e_stanowisko, e_login, e_haslo)
                            if ok:
                                st.success("Konto utworzone!");
                                time.sleep(1);
                                st.rerun()
                            else:
                                st.error(f"Błąd: {msg}")
                        else:
                            st.warning("Uzupełnij wszystkie pola.")
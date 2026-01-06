import streamlit as st
import pandas as pd
from db import run_query, run_command, check_login
import datetime
import time

st.set_page_config(page_title="System Wypożyczalni", layout="wide", initial_sidebar_state="expanded")

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
    .login-container {
        max-width: 400px;
        margin: auto;
        padding: 30px;
        border-radius: 10px;
        box-shadow: 0 4px 10px rgba(0,0,0,0.1);
        background-color: white;
        text-align: center;
    }
    </style>
""", unsafe_allow_html=True)


def get_client_id_by_pesel(pesel):
    res = run_query("SELECT id_klienta FROM Klienci WHERE pesel = %s", (pesel,))
    if not res.empty: return res.iloc[0]['id_klienta']
    return None


def add_new_client_fast(imie, nazwisko, pesel, nr_prawa, telefon, email, adres):
    sql = "CALL sp_dodaj_klienta(%s, %s, %s, %s, %s, %s, %s);"
    success, msg = run_command(sql, (imie, nazwisko, pesel, nr_prawa, telefon, email, adres))
    if not success: return False, msg, None
    new_id = get_client_id_by_pesel(pesel)
    return True, "Dodano klienta.", new_id


def add_employee(imie, nazwisko, stanowisko, login, haslo):
    sql = "CALL sp_dodaj_pracownika(%s, %s, %s, %s, %s);"
    return run_command(sql, (imie, nazwisko, stanowisko, login, haslo))


def delete_employee(emp_id):
    sql = "CALL sp_usun_pracownika(%s);"
    return run_command(sql, (emp_id,))


if 'logged_in' not in st.session_state: st.session_state['logged_in'] = False
if 'user_info' not in st.session_state: st.session_state['user_info'] = {}
if 'reservation_step' not in st.session_state: st.session_state['reservation_step'] = None
if 'selected_car_data' not in st.session_state: st.session_state['selected_car_data'] = None

if not st.session_state['logged_in']:
    c1, c2, c3 = st.columns([1, 1, 1])
    with c2:
        st.title("🔒 Logowanie")
        with st.form("login_form"):
            user = st.text_input("Login")
            pw = st.text_input("Hasło", type="password")
            if st.form_submit_button("Zaloguj się", type="primary", use_container_width=True):
                user_data = check_login(user, pw)
                if user_data:
                    st.session_state['logged_in'] = True
                    st.session_state['user_info'] = user_data
                    st.success(f"Witaj, {user_data['imie']}!")
                    st.rerun()
                else:
                    st.error("Błędny login lub hasło.")
    st.stop()

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
    if c_logout.button("Wyloguj"): st.session_state.clear(); st.rerun()
    if c_reset.button("Reset"): st.session_state['reservation_step'] = None; st.rerun()

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
    st.subheader("📊 Obłożenie w bieżącym miesiącu")
    now = datetime.date.today()
    df_chart = run_query("SELECT * FROM OblozenieMiesieczne(%s, %s)", (now.year, now.month))
    if not df_chart.empty:
        st.area_chart(df_chart.set_index("dzien")['liczba_aut'])
    else:
        st.info("Brak danych na ten miesiąc.")

elif menu == "🚗 Flota & Rezerwacje":
    st.title("🚗 Flota i Rezerwacje")

    with st.container(border=True):
        st.subheader("1. Znajdź samochód")
        c1, c2, c3 = st.columns([2, 2, 1])
        d_od = c1.date_input("Data Odbioru", datetime.date.today())
        d_do = c2.date_input("Data Zwrotu", datetime.date.today() + datetime.timedelta(days=3))
        st.session_state['dates'] = (d_od, d_do)

        if c3.button("🔍 Szukaj Wolnych Aut", type="primary", use_container_width=True):
            st.session_state['reservation_step'] = None
            st.session_state['search_performed'] = True

    if st.session_state.get('search_performed'):
        df_auta = run_query("SELECT * FROM ZnajdzDostepnePojazdy(%s, %s, NULL)", (d_od, d_do))
        if df_auta.empty:
            st.warning("Brak dostępnych aut w tym terminie.")
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

    if st.session_state['reservation_step'] == 'form' and st.session_state['selected_car_data'] is not None:
        car = st.session_state['selected_car_data']
        d_start, d_end = st.session_state['dates']
        days = (d_end - d_start).days
        if days < 1: days = 1
        price_total = days * car['cena']

        st.markdown("---")
        st.markdown(f"""<div class="reservation-box">
            <h3>📝 Finalizacja Rezerwacji: {car['marka']} {car['model']}</h3>
            <p>Termin: <b>{d_start}</b> do <b>{d_end}</b> ({days} dni)</p>
            <p style="font-size: 20px">Do zapłaty: <b>{price_total:.2f} PLN</b></p>
            <p>Obsługujący: <b>{user_name}</b></p>
        </div>""", unsafe_allow_html=True)
        st.write("")

        method = st.radio("Klient:", ["👤 Wybierz z bazy", "➕ Dodaj nowego klienta"], horizontal=True)
        selected_client_id = None

        with st.form("final_booking"):
            if method == "👤 Wybierz z bazy":
                clients_df = run_query("SELECT id_klienta, imie, nazwisko, pesel FROM Klienci ORDER BY Nazwisko")
                if not clients_df.empty:
                    options = {f"{r['nazwisko']} {r['imie']} ({r['pesel']})": r['id_klienta'] for i, r in
                               clients_df.iterrows()}
                    chosen = st.selectbox("Szukaj klienta:", list(options.keys()))
                    if chosen: selected_client_id = options[chosen]
                else:
                    st.warning("Brak klientów w bazie.")
            else:
                c1, c2 = st.columns(2)
                ni = c1.text_input("Imię");
                nn = c2.text_input("Nazwisko")
                np = c1.text_input("PESEL", max_chars=11);
                npr = c2.text_input("Prawo Jazdy")
                nt = c1.text_input("Telefon");
                ne = c2.text_input("Email");
                na = st.text_area("Adres")
                miejsce = st.text_input("Miejsce odbioru", "Siedziba Główna")

            if st.form_submit_button("✅ Potwierdź i Zarezerwuj", type="primary"):
                if method == "➕ Dodaj nowego klienta":
                    if not (ni and nn and np):
                        st.error("Brak danych osobowych!");
                        st.stop()
                    ok, msg, new_id = add_new_client_fast(ni, nn, np, npr, nt, ne, na)
                    if not ok: st.error(msg); st.stop()
                    selected_client_id = new_id

                cur_date = datetime.date.today()
                res_ok, res_msg = run_command("CALL sp_dodaj_rezerwacje(%s, %s, %s, %s, %s, %s, %s, %s, %s);",
                                              (selected_client_id, int(car['id_pojazdu']), user_id, cur_date, d_start,
                                               d_end, miejsce, float(price_total), 'Potwierdzona'))

                if res_ok:
                    st.balloons();
                    st.success("Rezerwacja udana!")
                    time.sleep(2)
                    st.session_state['reservation_step'] = None
                    st.session_state['selected_car_data'] = None
                    st.session_state['search_performed'] = False
                    st.rerun()
                else:
                    st.error(f"Błąd: {res_msg}")

        if st.button("❌ Anuluj"):
            st.session_state['reservation_step'] = None;
            st.rerun()

elif menu == "👥 Klienci":
    st.title("👥 Baza Klientów")
    search = st.text_input("🔍 Szukaj klienta:", placeholder="Nazwisko...")
    df = run_query("SELECT * FROM fn_pobierz_klientow()")
    if search:
        df = df[df.apply(lambda x: search.lower() in str(x).lower(), axis=1)]
    st.dataframe(df, use_container_width=True)

    with st.expander("📜 Historia (JSON)"):
        cid = st.number_input("ID Klienta", 1)
        if st.button("Pobierz"):
            res = run_query("SELECT PobierzHistorieKlientaJSON(%s) as j", (cid,))
            if not res.empty and res.iloc[0]['j']:
                st.json(res.iloc[0]['j'])

elif menu == "💰 Finanse":
    st.title("💰 Raporty Finansowe")
    rok = st.selectbox("Rok", [2023, 2024, 2025, 2026], index=3)
    df_fin = run_query("SELECT * FROM RaportPrzychodow(%s)", (rok,))
    if not df_fin.empty:
        c1, c2 = st.columns([1, 2])
        c1.dataframe(df_fin[['miesiac', 'razem', 'narastajaco']], use_container_width=True)
        c2.bar_chart(df_fin.set_index("miesiac")['razem'])
    else:
        st.warning("Brak danych.")

elif menu == "💼 Pracownicy (Admin)":
    st.title("💼 Zarządzanie Personelem")
    tab1, tab2 = st.tabs(["📊 Efektywność (Raport)", "🛠️ Zarządzaj Kontami"])

    with tab1:
        st.info("Ranking sprzedaży pracowników (kto ile zarobił dla firmy)")
        df_hr = run_query("SELECT * FROM EfektywnoscPracownikow()")
        if not df_hr.empty:
            st.dataframe(df_hr, use_container_width=True)
            st.bar_chart(df_hr.set_index("pracownik")['obrót'])

    with tab2:
        st.subheader("Lista Pracowników")
        staff = run_query(
            "SELECT id_pracownika, imie, nazwisko, stanowisko, login FROM Pracownicy ORDER BY id_pracownika")

        for i, row in staff.iterrows():
            c1, c2, c3, c4 = st.columns([1, 2, 2, 1])
            c1.write(row['id_pracownika'])
            c2.write(f"{row['imie']} {row['nazwisko']}")
            c3.write(row['stanowisko'])
            if c4.button("Usuń", key=f"del_{row['id_pracownika']}"):
                ok, msg = delete_employee(row['id_pracownika'])
                if ok:
                    st.success("Usunięto");
                    time.sleep(1);
                    st.rerun()
                else:
                    st.error(msg)

        st.markdown("---")
        st.subheader("Dodaj Pracownika")
        with st.form("new_emp"):
            col1, col2 = st.columns(2)
            e_imie = col1.text_input("Imię")
            e_nazwisko = col2.text_input("Nazwisko")
            e_stanowisko = st.selectbox("Stanowisko", ["Sprzedawca", "Serwisant", "Menadżer"])
            col3, col4 = st.columns(2)
            e_login = col3.text_input("Nowy Login")
            e_haslo = col4.text_input("Nowe Hasło", type="password")

            if st.form_submit_button("Utwórz Konto"):
                if e_imie and e_nazwisko and e_login and e_haslo:
                    try:
                        ok, msg = add_employee(e_imie, e_nazwisko, e_stanowisko, e_login, e_haslo)
                        if ok:
                            st.success("Dodano pracownika!")
                            time.sleep(1)
                            st.rerun()
                        else:
                            st.error(f"Błąd: {msg}")
                    except Exception as e:
                        st.error(f"Błąd: {e}")
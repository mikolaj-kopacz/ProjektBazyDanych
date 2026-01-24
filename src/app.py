import streamlit as st
import pandas as pd
import datetime
import time
from fpdf import FPDF

import db

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
    </style>
""",
    unsafe_allow_html=True,
)


# --- FUNKCJE POMOCNICZE (UI / PDF) ---

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
                    user_data = db.check_login(user, pw)
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
        stats = db.get_dashboard_stats()
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
        st.subheader("📊 Obłożenie Floty")

        now = datetime.date.today()
        m_names = ["Cały Rok", "Styczeń", "Luty", "Marzec", "Kwiecień", "Maj", "Czerwiec",
                   "Lipiec", "Sierpień", "Wrzesień", "Październik", "Listopad", "Grudzień"]

        f1, f2 = st.columns([1, 2])
        with f1:
            sel_year = st.number_input("Rok", value=now.year, step=1, format="%d")
        with f2:
            sel_month_idx = now.month
            sel_view = st.selectbox("Widok", m_names, index=sel_month_idx)

        try:
            df_chart = db.get_yearly_occupancy(sel_year)

            if not df_chart.empty:
                df_chart["dzien"] = pd.to_datetime(df_chart["dzien"])

                if sel_view != "Cały Rok":
                    month_num = m_names.index(sel_view)
                    df_chart = df_chart[df_chart["dzien"].dt.month == month_num]

                    if df_chart.empty:
                        st.info(f"Brak danych dla: {sel_view} {sel_year}")
                    else:
                        st.area_chart(df_chart.set_index("dzien")["liczba_aut"], color="#0068c9")
                else:
                    st.area_chart(df_chart.set_index("dzien")["liczba_aut"], color="#0068c9")
            else:
                st.warning(f"Brak danych w bazie dla roku {sel_year}.")

        except Exception as e:
            st.error(f"Błąd wykresu: {e}")

    with col_alerts:
        st.subheader("⚠️ Pilne Sprawy (Serwis)")
        try:
            df_serv = db.get_urgent_alerts(15000)
            if not df_serv.empty:
                st.error(f"Auta do sprawdzenia: {len(df_serv)}")
                st.dataframe(
                    df_serv[["pojazd", "problem", "priorytet"]],
                    hide_index=True,
                    use_container_width=True
                )
            else:
                st.success("Wszystko OK. Brak pilnych spraw.")
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
                    df_auta = db.find_available_vehicles(d_od, d_do)
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
                        cdf = db.get_all_clients()
                        if not cdf.empty:
                            copts = {f"{r['nazwisko']} {r['imie']} ({r['pesel']})": r['id_klienta'] for i, r in
                                     cdf.iterrows()}
                            chosen = st.selectbox("Klient", list(copts.keys()))
                            if chosen:
                                sel_client_id = int(copts[chosen])
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

                if st.form_submit_button("Potwierdź", type="primary"):
                    if method == "Nowy klient":
                        ok, msg, nid = db.add_new_client(ni, nn, np, npr, nt, ne, na)
                        if not ok:
                            st.error(msg)
                            st.stop()
                        sel_client_id = int(nid)

                    res_ok, res_msg = db.add_reservation(
                        sel_client_id,
                        int(car["id_pojazdu"]),
                        user_id,
                        d_start,
                        d_end,
                        float(price_total)
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
        st.subheader("🛠️ Centrum Zarządzania Flotą")
        try:
            all_cars = db.get_all_vehicles()
            if not all_cars.empty:
                all_cars = all_cars.drop_duplicates(subset=['id_pojazdu'])
        except Exception as e:
            st.error(f"Błąd bazy: {e}")
            all_cars = pd.DataFrame()

        if all_cars.empty:
            st.info("Brak pojazdów.")
        else:
            # Filtrowanie
            cars_service = all_cars[all_cars['status_dostepnosci'] == 'W serwisie']
            cars_active = all_cars[all_cars['status_dostepnosci'] != 'W serwisie']

            # 1. SEKCJA AKTYWNA
            st.markdown("### 🟢 Auta w eksploatacji")
            for idx, car in cars_active.iterrows():
                has_issue = car.get('wymaga_serwisu', False)

                LIMIT_KM = 15000
                przebieg_akt = int(car['przebieg'])
                ost_serwis = int(car.get('ost_serwis_km', 0))
                przejechane = przebieg_akt - ost_serwis
                zostalo = LIMIT_KM - przejechane
                procent_zuzycia = min(max(przejechane / LIMIT_KM, 0.0), 1.0)

                if przejechane >= LIMIT_KM:
                    progress_color = "red"
                    service_status = f"⚠️ Wymiana wymagana! ({przejechane - LIMIT_KM} km po terminie)"
                elif zostalo < 2000:
                    progress_color = "orange"
                    service_status = f"⏳ Zbliża się serwis (zostało {zostalo} km)"
                else:
                    progress_color = "green"
                    service_status = f"✅ Olej OK (zostało {zostalo} km)"

                header_icon = "⚠️" if has_issue or przejechane >= LIMIT_KM else "🚗"
                header_text = f"{header_icon} {car['marka']} {car['model']} ({car['numer_rejestracyjny']})"

                with st.expander(header_text, expanded=(has_issue or przejechane >= LIMIT_KM)):
                    st.caption(
                        f"📉 **Cykl serwisowy:** Przejechano {przejechane} km od ostatniego serwisu (Limit: {LIMIT_KM} km)")
                    st.progress(procent_zuzycia)
                    st.markdown(f"**Status:** {service_status}")

                    st.markdown("---")

                    c1, c2, c3 = st.columns([2, 2, 1.5])

                    with c1:
                        st.write(f"**Przebieg:** {car['przebieg']} km")
                        st.write(f"**Klasa:** {car['nazwa_klasy']}")
                        if has_issue:
                            st.error(f"🚨 **ZGŁOSZONA USTERKA:** {car.get('opis_usterki', 'Brak opisu')}")

                    with c2:
                        st.markdown("**Aktualizacja przebiegu**")
                        new_km = st.number_input("Nowy przebieg", value=int(car['przebieg']),
                                                 key=f"km_{car['id_pojazdu']}_{idx}")
                        if st.button("Zapisz km", key=f"s_{car['id_pojazdu']}_{idx}"):
                            db.update_vehicle_status(car['id_pojazdu'], new_km, car['stan_techniczny'],
                                                     car['status_dostepnosci'])
                            st.toast("Zapisano przebieg!")
                            time.sleep(0.5)
                            st.rerun()

                    with c3:
                        st.markdown("**Akcje**")

                        if st.button("🛢️ Potwierdź Przegląd", key=f"oil_{car['id_pojazdu']}_{idx}",
                                     help="Zresetuj licznik kilometrów"):
                            db.add_service_entry(
                                int(car['id_pojazdu']),
                                datetime.date.today(),
                                "Wymiana oleju / Przegląd",
                                500.0,
                                int(new_km)
                            )
                            st.success("Zresetowano licznik!")
                            time.sleep(1)
                            st.rerun()

                        if has_issue:
                            if st.button("Wyślij do warsztatu", key=f"send_{car['id_pojazdu']}_{idx}", type="primary"):
                                db.update_vehicle_status(
                                    car['id_pojazdu'], car['przebieg'], "Wymaga naprawy", "W serwisie",
                                    wymaga_serwisu=True, opis_usterki=car['opis_usterki']
                                )
                                st.rerun()
                        else:
                            usterka_input = st.text_input("Zgłoś usterkę", key=f"u_in_{car['id_pojazdu']}_{idx}",
                                                          placeholder="Np. stuki w silniku")
                            if st.button("🚩 Zgłoś", key=f"rep_{car['id_pojazdu']}_{idx}"):
                                if usterka_input:
                                    db.update_vehicle_status(
                                        car['id_pojazdu'], car['przebieg'], "Zgłoszono usterkę",
                                        car['status_dostepnosci'],
                                        wymaga_serwisu=True, opis_usterki=usterka_input
                                    )
                                    st.success("Zgłoszono!")
                                    time.sleep(0.5)
                                    st.rerun()

            st.markdown("---")

            # 2. SEKCJA SERWISOWA
            st.markdown("### 🔴 Warsztat (Auta w naprawie)")
            if cars_service.empty:
                st.caption("Warsztat jest pusty. Wszystkie auta sprawne!")
            else:
                for idx, car in cars_service.iterrows():
                    with st.container(border=True):
                        cols = st.columns([3, 1])
                        with cols[0]:
                            st.markdown(f"#### 🔧 {car['marka']} {car['model']} ({car['numer_rejestracyjny']})")
                            st.error(f"Powód naprawy: **{car.get('opis_usterki', 'Brak opisu')}**")
                        with cols[1]:
                            if st.button("✅ Naprawione", key=f"fix_{car['id_pojazdu']}_{idx}"):
                                db.add_service_entry(
                                    int(car['id_pojazdu']),
                                    datetime.date.today(),
                                    "Naprawa usterki",
                                    0.0,
                                    int(car['przebieg'])
                                )
                                db.update_vehicle_status(
                                    car['id_pojazdu'], car['przebieg'], "Idealny", "Dostępny",
                                    wymaga_serwisu=False, opis_usterki=""
                                )
                                st.balloons()
                                time.sleep(1)
                                st.rerun()

        # LOGIKA MENADŻERA
        if user_role == "Menadżer":
            st.markdown("---")
            st.markdown("#### ⚡ Panel Menadżera")

            mt1, mt2, mt3 = st.tabs(["➕ Dodaj Samochód", "✏️ Edytuj Auto", "🗑️ Usuń Samochód"])

            with mt1:
                with st.form("new_car"):
                    clss = db.get_vehicle_classes()
                    if not clss.empty:
                        copt = {f"{r['nazwa_klasy']}": r['id_klasy'] for i, r in clss.iterrows()}
                        sc = st.selectbox("Klasa", list(copt.keys()))
                        c1, c2 = st.columns(2)
                        ma = c1.text_input("Marka")
                        mo = c2.text_input("Model")
                        ro = c1.number_input("Rok", 2000, 2030, 2023)
                        nr = c2.text_input("Rejestracja")
                        km = c1.number_input("Przebieg", 0)

                        if st.form_submit_button("Dodaj do floty"):
                            ok, m = db.add_vehicle(copt[sc], ma, mo, ro, nr, km, "Idealny", "Dostępny")
                            if ok:
                                st.success("Dodano nowe auto!")
                                time.sleep(1)
                                st.rerun()
                            else:
                                st.error(m)

            with mt2:
                if not all_cars.empty:
                    opts_edit = {
                        f"#{r['id_pojazdu']} {r['marka']} {r['model']} ({r['numer_rejestracyjny']})": r['id_pojazdu']
                        for i, r in all_cars.iterrows()}
                    sel_edit = st.selectbox("Wybierz auto do edycji", list(opts_edit.keys()), key="sel_edit_car")

                    if sel_edit:
                        car_id = opts_edit[sel_edit]
                        curr_car = all_cars[all_cars['id_pojazdu'] == car_id].iloc[0]

                        st.info("💡 Edytujesz dane techniczne pojazdu.")

                        with st.form("edit_car_full"):
                            clss = db.get_vehicle_classes()
                            copt = {f"{r['nazwa_klasy']}": r['id_klasy'] for i, r in clss.iterrows()}

                            new_class_name = st.selectbox("Klasa", list(copt.keys()), key="ed_cls")
                            new_class_id = copt[new_class_name]

                            ec1, ec2 = st.columns(2)
                            e_marka = ec1.text_input("Marka", value=curr_car['marka'])
                            e_model = ec2.text_input("Model", value=curr_car['model'])
                            e_rok = ec1.number_input("Rok Produkcji", 1990, 2030, int(curr_car['rok_produkcji']))
                            e_rej = ec2.text_input("Nr Rejestracyjny", value=curr_car['numer_rejestracyjny'])
                            e_przebieg = ec1.number_input("Przebieg", 0, 1000000, int(curr_car['przebieg']))
                            e_stan = ec2.text_input("Opis Stanu", value=curr_car['stan_techniczny'])

                            if st.form_submit_button("💾 Zapisz zmiany w pojeździe"):
                                ok, m = db.update_vehicle_full_details(
                                    car_id, new_class_id, e_marka, e_model, e_rok, e_rej, e_przebieg, e_stan
                                )
                                if ok:
                                    st.success("Dane pojazdu zaktualizowane!")
                                    time.sleep(1)
                                    st.rerun()
                                else:
                                    st.error(f"Błąd edycji: {m}")
                else:
                    st.warning("Brak aut do edycji.")

            with mt3:
                if not all_cars.empty:
                    opts = {f"#{r['id_pojazdu']} {r['marka']} {r['model']}": r['id_pojazdu'] for i, r in
                            all_cars.iterrows()}
                    tod = st.selectbox("Wybierz auto do usunięcia", list(opts.keys()), key="del_c_manager")
                    if st.button("Usuń trwale", key="btn_del_manager"):
                        ok, m = db.delete_vehicle(opts[tod])
                        if ok:
                            st.success("Usunięto")
                            time.sleep(1)
                            st.rerun()
                        else:
                            st.error(m)

    with tab_analysis:
        st.subheader("📊 Analizy Floty")

        st.markdown("#### 🔍 Szukaj pojazdu")
        fraza = st.text_input("Wpisz markę, model lub rejestrację:")
        if fraza:
            rs = db.search_vehicles(fraza)
            st.dataframe(rs, use_container_width=True)

        st.markdown("---")

        st.markdown("#### 💤 Analiza Przestojów ")
        st.caption("Pokaż auta, które stały bezczynnie między wypożyczeniami dłużej niż:")

        dni = st.slider("Minimalna liczba dni przestoju", 1, 30, 7)

        if st.button("Analizuj przestoje"):
            try:
                df_down = db.get_downtime_analysis(dni)
                if not df_down.empty:
                    st.warning(f"Znaleziono {len(df_down)} przypadków długiego postoju.")
                    st.dataframe(
                        df_down,
                        column_config={
                            "dni_przestoju": st.column_config.NumberColumn("Dni bez pracy", format="%d dni 💤"),
                            "data_zwrotu": "Od (Zwrot)",
                            "data_nastepnego_odbioru": "Do (Nast. Odbiór)"
                        },
                        use_container_width=True
                    )
                else:
                    st.success("Świetnie! Auta rotują bardzo sprawnie (brak długich przestojów).")
            except Exception as e:
                st.error(f"Błąd analizy: {e}")

# ----------------- KLIENCI -----------------
elif menu == "👥 Klienci":
    st.title("👥 Zarządzanie Klientami")
    tab_list, tab_add, tab_manage, tab_crm = st.tabs(
        ["📂 Przeglądaj", "➕ Dodaj Nowego", "✏️ Zarządzaj (Edytuj/Usuń)", "🏆 CRM"])

    with tab_list:
        st.subheader("Lista Klientów")
        search_q = st.text_input("🔍 Filtruj (Nazwisko/PESEL):")
        try:
            df_cli = db.get_all_clients()
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
                h = db.get_client_history_json(cid_hist)
                if not h.empty and h.iloc[0]['j']:
                    st.json(h.iloc[0]['j'])
        except Exception as e:
            st.error(f"Błąd: {e}")

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
                    ok, msg, new_id = db.add_new_client(i, n, p, pj, t, e, a)
                    if ok:
                        st.success(f"Klient dodany! ID: {new_id}")
                        time.sleep(1)
                        st.rerun()
                    else:
                        st.error(msg)
                else:
                    st.warning("Wymagane pola: Imię, Nazwisko, PESEL, Prawo Jazdy.")

    with tab_manage:
        st.subheader("Edycja i Usuwanie")
        try:
            df_cli_m = db.get_all_clients()
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
                            ok, msg = db.update_client(int(sel_id), ei, en, ep, epj, et, ee, ea)
                            if ok:
                                st.success("Dane zaktualizowane!")
                                time.sleep(1)
                                st.rerun()
                            else:
                                st.error(msg)

                with col_del:
                    st.markdown("#### 🗑️ Usuń Klienta")
                    st.warning(
                        "Uwaga: Usunięcie jest możliwe tylko, jeśli klient nie ma historii wypożyczeń w ciągu ostatniego roku.")
                    if st.button("Usuń trwale z bazy", type="primary"):
                        ok, msg = db.delete_client(int(sel_id))
                        if ok:
                            st.success("Klient usunięty.")
                            time.sleep(1)
                            st.rerun()
                        else:
                            st.error(msg)
        else:
            st.info("Brak klientów do zarządzania.")

    with tab_crm:
        c1, c2 = st.columns(2)
        with c1:
            st.markdown("#### Statusy")
            try:
                st.dataframe(db.get_client_statuses(), hide_index=True)
            except Exception as e:
                st.error(str(e))
        with c2:
            st.markdown("#### Ranking VIP")
            try:
                st.dataframe(db.get_vip_ranking(5), hide_index=True)
            except Exception as e:
                st.error(f"Błąd SQL (CRM): {e}")

# ----------------- FINANSE -----------------
elif menu == "💰 Finanse":
    st.title("💰 Raporty Finansowe")
    rok = st.selectbox("Rok", [2023, 2024, 2025, 2026], index=2)
    try:
        df_fin = db.get_revenue_report(rok)
        if not df_fin.empty:
            st.markdown(f"### Wyniki za rok {rok}")

            st.dataframe(
                df_fin[["miesiac", "przychod", "zmiana_procentowa", "udzial_w_roku"]],
                use_container_width=True
            )

            st.markdown("#### 📈 Wykres przychodów (Miesięcznie)")
            st.bar_chart(df_fin.set_index("miesiac")["przychod"])
        else:
            st.warning("Brak danych finansowych dla wybranego roku.")
    except Exception as e:
        st.error(f"Błąd generowania raportu: {e}")

# ----------------- PRACOWNICY -----------------
elif menu == "💼 Pracownicy (Admin)":
    st.title("💼 Zarządzanie Personelem")
    t1, t2 = st.tabs(["Efektywność", "Konta (Edycja / Dodawanie / Usuwanie)"])

    with t1:
        st.info("Ranking sprzedaży pracowników (kto ile zarobił dla firmy)")
        try:
            hr = db.get_employee_efficiency()
            st.dataframe(hr, use_container_width=True)
            if not hr.empty:
                st.bar_chart(hr.set_index("pracownik")["obrót"])
        except Exception as e:
            st.error(str(e))

    with t2:
        try:
            staff = db.get_employees()
        except:
            staff = pd.DataFrame()

        st.markdown("### 1. Lista Pracowników")
        if not staff.empty:
            for _, r in staff.iterrows():
                c1, c2, c3 = st.columns([3, 2, 1])
                with c1:
                    st.write(f"**{r['imie']} {r['nazwisko']}**")
                    st.caption(f"Stanowisko: {r['stanowisko']}")
                with c2:
                    st.write(f"Login: `{r['login']}`")
                with c3:
                    if str(r['id_pracownika']) != str(user_id) and r['login'] != 'admin':
                        if st.button("🗑️ Usuń", key=f"del_st_{r['id_pracownika']}"):
                            db.delete_employee(r['id_pracownika'])
                            st.success("Usunięto.")
                            time.sleep(0.5)
                            st.rerun()
                    else:
                        st.write("🔒")
            st.markdown("---")
        else:
            st.warning("Brak pracowników w bazie.")

        col_edit, col_add = st.columns(2)

        with col_edit:
            st.subheader("✏️ Edytuj Dane")
            with st.container(border=True):
                if not staff.empty:
                    opts_emp = {f"{r['nazwisko']} {r['imie']} ({r['stanowisko']})": r['id_pracownika'] for _, r in
                                staff.iterrows()}
                    sel_emp_label = st.selectbox("Wybierz pracownika do zmiany:", list(opts_emp.keys()))

                    if sel_emp_label:
                        emp_id_edit = opts_emp[sel_emp_label]
                        curr_emp = staff[staff['id_pracownika'] == emp_id_edit].iloc[0]

                        with st.form("edit_emp_form"):
                            new_imie = st.text_input("Imię", value=curr_emp['imie'])
                            new_nazwisko = st.text_input("Nazwisko", value=curr_emp['nazwisko'])
                            stanowiska = ["Sprzedawca", "Serwisant", "Menadżer"]
                            try:
                                curr_idx = stanowiska.index(curr_emp['stanowisko'])
                            except ValueError:
                                curr_idx = 0
                            new_stanowisko = st.selectbox("Stanowisko", stanowiska, index=curr_idx)
                            st.caption("Loginu i hasła nie można zmienić w tym panelu.")

                            if st.form_submit_button("💾 Zapisz zmiany"):
                                ok, msg = db.update_employee(int(emp_id_edit), new_imie, new_nazwisko, new_stanowisko)
                                if ok:
                                    st.success("Zaktualizowano dane pracownika!")
                                    time.sleep(1)
                                    st.rerun()
                                else:
                                    st.error(msg)
                else:
                    st.info("Brak pracowników do edycji.")

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
                            ok, m = db.add_employee(ei, en, es, el, ep)
                            if ok:
                                st.success("Pracownik dodany!")
                                time.sleep(1)
                                st.rerun()
                            else:
                                st.error(m)
                        else:
                            st.warning("Uzupełnij wszystkie pola.")
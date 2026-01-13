# 🚗 Rent-A-Car OS - System Obsługi Wypożyczalni

Projekt zaliczeniowy z przedmiotu **Bazy Danych** (Semestr 2).  
Kompleksowy system do zarządzania wypożyczalnią samochodów, obejmujący bazę danych PostgreSQL (z zaawansowaną logiką PL/pgSQL) oraz interfejs graficzny w Pythonie (Streamlit).

## 📋 Opis Projektu

System umożliwia pełną obsługę procesów biznesowych wypożyczalni, w tym:
* Zarządzanie flotą pojazdów (dodawanie, edycja, statusy, serwis).
* Obsługę klientów (CRM, historia wypożyczeń, statusy VIP).
* Rezerwacje pojazdów z weryfikacją dostępności.
* Generowanie potwierdzeń PDF.
* Raportowanie finansowe i analizy biznesowe.

## 🛠 Technologie

* **Baza danych:** PostgreSQL 14+
* **Język proceduralny:** PL/pgSQL (Procedury, Funkcje, Wyzwalacze)
* **Backend/Frontend:** Python 3.12 + Streamlit
* **Zarządzanie zależnościami:** uv (nowoczesny manager pakietów Python)
* **Biblioteki:** pandas, psycopg2, fpdf2, plotly

## 🚀 Funkcjonalności Bazy Danych (Algorytmy)

System implementuje 10 kluczowych algorytmów po stronie bazy danych:
1.  **Wyszukiwanie dostępnych aut:** Uwzględnia rezerwacje i wyklucza auta w serwisie.
2.  **Prognoza serwisowa:** Oblicza km pozostałe do przeglądu.
3.  **Raport finansowy:** Zestawienie miesięczne z sumą narastającą.
4.  **Ranking VIP:** Segmentacja klientów (Platynowy, Złoty, Srebrny).
5.  **Analiza przestojów:** Wykrywanie aut nieużywanych od X dni.
6.  **Kalendarz obłożenia:** Statystyki wynajmu dzień po dniu.
7.  **Efektywność pracowników:** Ocena sprzedaży personelu.
8.  **Status lojalnościowy:** Wykrywanie klientów uśpionych/utraconych.
9.  **Historia klienta (JSON):** Eksport danych do formatu JSON.
10. **Wyszukiwarka pojazdów:** Szybkie szukanie po frazie.

---

## ⚙️ Instrukcja Uruchomienia

Aby uruchomić projekt na własnym komputerze, wykonaj poniższe kroki.

### Krok 1: Wymagania wstępne
Upewnij się, że masz zainstalowane:
* PostgreSQL
* Python 3.12+
* uv (zalecane) lub pip.

### Krok 2: Konfiguracja Bazy Danych

1.  Uruchom narzędzie do zarządzania bazą (np. pgAdmin, DBeaver lub terminal psql).
2.  Utwórz nową bazę danych o nazwie: wypozyczalnia_db
3.  Wykonaj skrypty SQL w podanej kolejności:
    * Najpierw: setup.sql (tworzy tabele, funkcje i procedury).
    * Następnie: dane.sql (ładuje przykładowe dane testowe).

### Krok 3: Uruchomienie Aplikacji (przez uv)

Projekt korzysta z managera uv dla szybszej instalacji zależności.

1.  Otwórz terminal w katalogu projektu.
2.  Przejdź do folderu źródłowego:
    cd src

3.  Zainstaluj zależności i zsynchronizuj środowisko:
    uv sync

4.  Uruchom aplikację:
    uv run streamlit run app.py

### Alternatywnie (przez standardowy pip)

Jeśli nie chcesz używać uv:
    cd src
    pip install -r requirements.txt
    streamlit run app.py

---

## 🔑 Dane Logowania (Demo)

Po uruchomieniu aplikacji zobaczysz ekran logowania. Użyj danych testowych zdefiniowanych w bazie:

| Rola | Login | Hasło |
| :--- | :--- | :--- |
| Menadżer (Admin) | admin | admin |
| Sprzedawca | ewa | ewa |
| Serwisant | piotr | piotr |

---

## 📝 Konfiguracja Połączenia z Bazą

Domyślnie aplikacja łączy się z:
* Host: localhost
* Port: 5432
* DB: wypozyczalnia_db
* User: postgres
* Pass: admin

Aby zmienić te ustawienia bez edycji kodu, utwórz plik .streamlit/secrets.toml wewnątrz folderu src o treści:

[postgres]
host = "localhost"
port = "5432"
dbname = "twoja_nazwa_bazy"
user = "twoj_uzytkownik"
password = "twoje_haslo"

---

## 👥 Autorzy

* **Mikołaj Kopacz** – Architektura bazy danych, Backend, Frontend.
---------------------------------------------------------------------------------
-- 1. CZYSZCZENIE
---------------------------------------------------------------------------------
-- Procedury CRUD
DROP PROCEDURE IF EXISTS sp_dodaj_klienta CASCADE;
DROP PROCEDURE IF EXISTS sp_aktualizuj_klienta CASCADE;
DROP PROCEDURE IF EXISTS sp_usun_klienta CASCADE;
DROP PROCEDURE IF EXISTS sp_dodaj_pracownika CASCADE;
DROP PROCEDURE IF EXISTS sp_aktualizuj_pracownika CASCADE;
DROP PROCEDURE IF EXISTS sp_usun_pracownika CASCADE;
DROP PROCEDURE IF EXISTS sp_dodaj_klase CASCADE;
DROP PROCEDURE IF EXISTS sp_aktualizuj_klase CASCADE;
DROP PROCEDURE IF EXISTS sp_usun_klase CASCADE;
DROP PROCEDURE IF EXISTS sp_dodaj_pojazd CASCADE;
DROP PROCEDURE IF EXISTS sp_aktualizuj_pojazd CASCADE;
DROP PROCEDURE IF EXISTS sp_usun_pojazd CASCADE;
DROP PROCEDURE IF EXISTS sp_dodaj_rezerwacje CASCADE;
DROP PROCEDURE IF EXISTS sp_aktualizuj_rezerwacje CASCADE;
DROP PROCEDURE IF EXISTS sp_usun_rezerwacje CASCADE;
DROP PROCEDURE IF EXISTS sp_dodaj_usluge CASCADE;
DROP PROCEDURE IF EXISTS sp_aktualizuj_usluge CASCADE;
DROP PROCEDURE IF EXISTS sp_usun_usluge CASCADE;
DROP PROCEDURE IF EXISTS sp_dodaj_usluge_do_rezerwacji CASCADE;
DROP PROCEDURE IF EXISTS sp_aktualizuj_usluge_rezerwacji CASCADE;
DROP PROCEDURE IF EXISTS sp_usun_usluge_z_rezerwacji CASCADE;
DROP PROCEDURE IF EXISTS sp_dodaj_platnosc CASCADE;
DROP PROCEDURE IF EXISTS sp_aktualizuj_platnosc CASCADE;
DROP PROCEDURE IF EXISTS sp_usun_platnosc CASCADE;
DROP PROCEDURE IF EXISTS sp_dodaj_serwis CASCADE;
DROP PROCEDURE IF EXISTS sp_aktualizuj_serwis CASCADE;
DROP PROCEDURE IF EXISTS sp_usun_serwis CASCADE;

-- Funkcje pomocnicze (READ)
DROP FUNCTION IF EXISTS fn_pobierz_klientow CASCADE;
DROP FUNCTION IF EXISTS fn_pobierz_pracownikow CASCADE;
DROP FUNCTION IF EXISTS fn_pobierz_klasy CASCADE;
DROP FUNCTION IF EXISTS fn_pobierz_pojazdy CASCADE;
DROP FUNCTION IF EXISTS fn_pobierz_rezerwacje CASCADE;
DROP FUNCTION IF EXISTS fn_pobierz_uslugi CASCADE;
DROP FUNCTION IF EXISTS fn_pobierz_uslugi_rezerwacji CASCADE;
DROP FUNCTION IF EXISTS fn_pobierz_platnosci CASCADE;
DROP FUNCTION IF EXISTS fn_pobierz_serwisy CASCADE;

-- Funkcje Algorytmiczne (Zapytania)
DROP FUNCTION IF EXISTS ZnajdzDostepnePojazdy CASCADE;
DROP FUNCTION IF EXISTS RaportPrzychodow CASCADE;
DROP FUNCTION IF EXISTS RankingKlientowVIP CASCADE;
DROP FUNCTION IF EXISTS AnalizaPrzestojow CASCADE;
DROP FUNCTION IF EXISTS PobierzHistorieKlientaJSON CASCADE;
DROP FUNCTION IF EXISTS OblozenieMiesieczne CASCADE;
DROP FUNCTION IF EXISTS OblozenieRoczne CASCADE;
DROP FUNCTION IF EXISTS EfektywnoscPracownikow CASCADE;
DROP FUNCTION IF EXISTS StatusKlientow CASCADE;
DROP FUNCTION IF EXISTS PrognozaSerwisowa CASCADE;
DROP FUNCTION IF EXISTS SzukajPojazdu CASCADE;

-- funkcje pomocnicze dla UI
DROP FUNCTION IF EXISTS fn_statystyki_pulpit CASCADE;
DROP FUNCTION IF EXISTS fn_znajdz_klienta_pesel CASCADE;
DROP FUNCTION IF EXISTS fn_pobierz_pojazdy_alert CASCADE;

-- Tabele
DROP TABLE IF EXISTS Platnosci CASCADE;
DROP TABLE IF EXISTS Rezerwacje_Uslugi CASCADE;
DROP TABLE IF EXISTS Uslugi_Dodatkowe CASCADE;
DROP TABLE IF EXISTS Serwisy CASCADE;
DROP TABLE IF EXISTS Rezerwacje CASCADE;
DROP TABLE IF EXISTS Pojazdy CASCADE;
DROP TABLE IF EXISTS Klienci CASCADE;
DROP TABLE IF EXISTS Pracownicy CASCADE;
DROP TABLE IF EXISTS Klasy_Pojazdow CASCADE;

---------------------------------------------------------------------------------
-- 2. TWORZENIE STRUKTURY TABEL
---------------------------------------------------------------------------------
CREATE TABLE Klasy_Pojazdow (
    ID_Klasy SERIAL PRIMARY KEY,
    Nazwa_Klasy VARCHAR(50) UNIQUE NOT NULL,
    Cena_Za_Dobe DECIMAL(10, 2) NOT NULL
);

CREATE TABLE Pracownicy (
    ID_Pracownika SERIAL PRIMARY KEY,
    Imie VARCHAR(50) NOT NULL,
    Nazwisko VARCHAR(50) NOT NULL,
    Stanowisko VARCHAR(50),
    Login VARCHAR(50) UNIQUE NOT NULL,
    Haslo VARCHAR(50) NOT NULL
);

CREATE TABLE Klienci (
    ID_Klienta SERIAL PRIMARY KEY,
    Imie VARCHAR(50) NOT NULL,
    Nazwisko VARCHAR(50) NOT NULL,
    PESEL VARCHAR(11) UNIQUE NOT NULL,
    Numer_Prawa_Jazdy VARCHAR(20) UNIQUE NOT NULL,
    Telefon VARCHAR(15),
    Email VARCHAR(100),
    Adres TEXT
);

CREATE TABLE Pojazdy (
    ID_Pojazdu SERIAL PRIMARY KEY,
    ID_Klasy INT REFERENCES Klasy_Pojazdow(ID_Klasy),
    Marka VARCHAR(50) NOT NULL,
    Model VARCHAR(50) NOT NULL,
    Rok_Produkcji INT,
    Numer_Rejestracyjny VARCHAR(20) UNIQUE NOT NULL,
    Przebieg INT,
    Stan_Techniczny VARCHAR(50),
    Status_Dostepnosci VARCHAR(20) CHECK (Status_Dostepnosci IN ('Dostępny', 'Wypożyczony', 'W serwisie')),
    Wymaga_Serwisu BOOLEAN DEFAULT FALSE,
    Opis_Usterki TEXT DEFAULT NULL
);

CREATE TABLE Rezerwacje (
    ID_Rezerwacji SERIAL PRIMARY KEY,
    ID_Klienta INT REFERENCES Klienci(ID_Klienta),
    ID_Pojazdu INT REFERENCES Pojazdy(ID_Pojazdu),
    ID_Pracownika INT REFERENCES Pracownicy(ID_Pracownika),
    Data_Rezerwacji DATE DEFAULT CURRENT_DATE,
    Data_Odbioru DATE NOT NULL,
    Data_Zwrotu DATE NOT NULL,
    Miejsce_Odbioru VARCHAR(100),
    Cena_Calkowita DECIMAL(10, 2),
    Status_Rezerwacji VARCHAR(20) CHECK (Status_Rezerwacji IN ('Potwierdzona', 'Anulowana', 'Zakończona', 'W trakcie')),
    CHECK (Data_Zwrotu >= Data_Odbioru)
);

CREATE TABLE Serwisy (
    ID_Serwisu SERIAL PRIMARY KEY,
    ID_Pojazdu INT REFERENCES Pojazdy(ID_Pojazdu),
    Data_Serwisu DATE NOT NULL,
    Opis TEXT,
    Koszt DECIMAL(10, 2),
    Przebieg_W_Chwili_Serwisu INT
);

CREATE TABLE Uslugi_Dodatkowe (
    ID_Uslugi SERIAL PRIMARY KEY,
    Nazwa_Uslugi VARCHAR(100) NOT NULL,
    Cena DECIMAL(10, 2) NOT NULL
);

CREATE TABLE Rezerwacje_Uslugi (
    ID_Rezerwacji_Uslugi SERIAL PRIMARY KEY,
    ID_Rezerwacji INT REFERENCES Rezerwacje(ID_Rezerwacji),
    ID_Uslugi INT REFERENCES Uslugi_Dodatkowe(ID_Uslugi),
    UNIQUE(ID_Rezerwacji, ID_Uslugi)
);

CREATE TABLE Platnosci (
    ID_Platnosci SERIAL PRIMARY KEY,
    ID_Rezerwacji INT REFERENCES Rezerwacje(ID_Rezerwacji),
    Kwota_Calkowita DECIMAL(10, 2) NOT NULL,
    Data_Platnosci DATE DEFAULT CURRENT_DATE,
    Forma_Platnosci VARCHAR(20) CHECK (Forma_Platnosci IN ('Gotówka', 'Karta', 'Przelew')),
    Status_Platnosci VARCHAR(20) CHECK (Status_Platnosci IN ('Oczekująca', 'Zrealizowana', 'Anulowana')),
    Numer_Faktury VARCHAR(50)
);

---------------------------------------------------------------------------------
-- 3. CRUDY
---------------------------------------------------------------------------------

-- === 1. KLIENCI ===

-- 1A. Dodaj Klienta
CREATE OR REPLACE PROCEDURE sp_dodaj_klienta(
    p_imie VARCHAR, p_nazwisko VARCHAR, p_pesel VARCHAR,
    p_nr_prawa VARCHAR, p_telefon VARCHAR, p_email VARCHAR, p_adres VARCHAR
) LANGUAGE plpgsql AS $$
BEGIN
    IF EXISTS (SELECT 1 FROM Klienci WHERE PESEL = p_pesel) THEN
        RAISE EXCEPTION 'Błąd: Klient o podanym numerze PESEL (%) już istnieje!', p_pesel;
    END IF;
    IF EXISTS (SELECT 1 FROM Klienci WHERE Numer_Prawa_Jazdy = p_nr_prawa) THEN
        RAISE EXCEPTION 'Błąd: Numer Prawa Jazdy (%) jest już przypisany do innego klienta!', p_nr_prawa;
    END IF;

    INSERT INTO Klienci (Imie, Nazwisko, PESEL, Numer_Prawa_Jazdy, Telefon, Email, Adres)
    VALUES (p_imie, p_nazwisko, p_pesel, p_nr_prawa, p_telefon, p_email, p_adres);
END;
$$;

-- 1B. Pobierz Klientów
CREATE OR REPLACE FUNCTION fn_pobierz_klientow(p_id INT DEFAULT NULL)
RETURNS TABLE (ID_Klienta INT, Imie VARCHAR, Nazwisko VARCHAR, PESEL VARCHAR, Nr_Prawa_Jazdy VARCHAR, Telefon VARCHAR, Email VARCHAR, Adres TEXT)
LANGUAGE plpgsql AS $$
BEGIN
    RETURN QUERY
    SELECT k.ID_Klienta, k.Imie, k.Nazwisko, k.PESEL, k.Numer_Prawa_Jazdy, k.Telefon, k.Email, k.Adres
    FROM Klienci k
    WHERE p_id IS NULL OR k.ID_Klienta = p_id
    ORDER BY k.Nazwisko, k.Imie;
END;
$$;

-- 1C. Aktualizuj Klienta
CREATE OR REPLACE PROCEDURE sp_aktualizuj_klienta(
    p_id INT, p_imie VARCHAR, p_nazwisko VARCHAR, p_pesel VARCHAR,
    p_nr_prawa VARCHAR, p_telefon VARCHAR, p_email VARCHAR, p_adres VARCHAR
) LANGUAGE plpgsql AS $$
BEGIN
    IF p_pesel IS NOT NULL AND EXISTS (SELECT 1 FROM Klienci WHERE PESEL = p_pesel AND ID_Klienta != p_id) THEN
        RAISE EXCEPTION 'Błąd: Podany PESEL należy już do innego klienta!';
    END IF;

    UPDATE Klienci
    SET Imie = COALESCE(p_imie, Imie),
        Nazwisko = COALESCE(p_nazwisko, Nazwisko),
        PESEL = COALESCE(p_pesel, PESEL),
        Numer_Prawa_Jazdy = COALESCE(p_nr_prawa, Numer_Prawa_Jazdy),
        Telefon = COALESCE(p_telefon, Telefon),
        Email = COALESCE(p_email, Email),
        Adres = COALESCE(p_adres, Adres)
    WHERE ID_Klienta = p_id;

    IF NOT FOUND THEN
        RAISE EXCEPTION 'Nie znaleziono klienta o ID %', p_id;
    END IF;
END;
$$;

-- 1D. Usuń Klienta (WERSJA RODO + BLOKADA AKTYWNYCH)
CREATE OR REPLACE PROCEDURE sp_usun_klienta(p_id INT)
LANGUAGE plpgsql AS $$
DECLARE
    v_ostatnia_data DATE;
    v_aktywne INT;
BEGIN
    IF NOT EXISTS (SELECT 1 FROM Klienci WHERE ID_Klienta = p_id) THEN
        RAISE EXCEPTION 'Nie znaleziono klienta o ID %', p_id;
    END IF;

    SELECT COUNT(*) INTO v_aktywne
    FROM Rezerwacje
    WHERE ID_Klienta = p_id
      AND Status_Rezerwacji NOT IN ('Zakończona', 'Anulowana');

    IF v_aktywne > 0 THEN
        RAISE EXCEPTION 'Błąd: Nie można usunąć klienta, który ma aktywne rezerwacje (auto nie zostało zwrócone)!';
    END IF;

    SELECT MAX(Data_Zwrotu) INTO v_ostatnia_data
    FROM Rezerwacje
    WHERE ID_Klienta = p_id;

    IF v_ostatnia_data IS NOT NULL AND v_ostatnia_data > (CURRENT_DATE - INTERVAL '1 year') THEN
        RAISE EXCEPTION 'Błąd: RODO / Bezpieczeństwo. Ostatnie wypożyczenie zakończyło się %, co jest okresem krótszym niż rok. Musimy trzymać dane.', v_ostatnia_data;
    END IF;

    UPDATE Rezerwacje
    SET ID_Klienta = NULL
    WHERE ID_Klienta = p_id;

    DELETE FROM Klienci WHERE ID_Klienta = p_id;

    RAISE NOTICE 'Klient o ID % został usunięty.', p_id;
END;
$$;

-- === 2. PRACOWNICY ===

-- 2A. Dodaj Pracownika
CREATE OR REPLACE PROCEDURE sp_dodaj_pracownika(
    p_imie VARCHAR, p_nazwisko VARCHAR, p_stanowisko VARCHAR,
    p_login VARCHAR, p_haslo VARCHAR
) LANGUAGE plpgsql AS $$
BEGIN
    IF EXISTS (SELECT 1 FROM Pracownicy WHERE Login = p_login) THEN
        RAISE EXCEPTION 'Błąd: Login "%" jest już zajęty!', p_login;
    END IF;

    INSERT INTO Pracownicy (Imie, Nazwisko, Stanowisko, Login, Haslo)
    VALUES (p_imie, p_nazwisko, p_stanowisko, p_login, p_haslo);
END;
$$;

-- 2B. Pobierz Pracowników
CREATE OR REPLACE FUNCTION fn_pobierz_pracownikow(p_id INT DEFAULT NULL)
RETURNS TABLE (ID_Pracownika INT, Imie VARCHAR, Nazwisko VARCHAR, Stanowisko VARCHAR, Login VARCHAR)
LANGUAGE plpgsql AS $$
BEGIN
    RETURN QUERY
    SELECT p.ID_Pracownika, p.Imie, p.Nazwisko, p.Stanowisko, p.Login
    FROM Pracownicy p
    WHERE p_id IS NULL OR p.ID_Pracownika = p_id
    ORDER BY p.ID_Pracownika;
END;
$$;

-- 2C. Aktualizuj Pracownika
CREATE OR REPLACE PROCEDURE sp_aktualizuj_pracownika(
    p_id INT, p_imie VARCHAR, p_nazwisko VARCHAR, p_stanowisko VARCHAR
) LANGUAGE plpgsql AS $$
BEGIN
    UPDATE Pracownicy
    SET Imie = COALESCE(p_imie, Imie),
        Nazwisko = COALESCE(p_nazwisko, Nazwisko),
        Stanowisko = COALESCE(p_stanowisko, Stanowisko)
    WHERE ID_Pracownika = p_id;
END;
$$;

-- 2D. Usuń Pracownika
CREATE OR REPLACE PROCEDURE sp_usun_pracownika(p_id INT)
LANGUAGE plpgsql AS $$
BEGIN
    UPDATE Rezerwacje SET ID_Pracownika = NULL WHERE ID_Pracownika = p_id;
    DELETE FROM Pracownicy WHERE ID_Pracownika = p_id;
END;
$$;

-- === 3. KLASY POJAZDÓW ===

CREATE OR REPLACE PROCEDURE sp_dodaj_klase(
    p_nazwa VARCHAR, p_cena DECIMAL
) LANGUAGE plpgsql AS $$
BEGIN
    INSERT INTO Klasy_Pojazdow (Nazwa_Klasy, Cena_Za_Dobe) VALUES (p_nazwa, p_cena);
END;
$$;

CREATE OR REPLACE FUNCTION fn_pobierz_klasy(p_id INT DEFAULT NULL)
RETURNS SETOF Klasy_Pojazdow LANGUAGE plpgsql AS $$
BEGIN
    RETURN QUERY SELECT * FROM Klasy_Pojazdow k WHERE p_id IS NULL OR k.ID_Klasy = p_id ORDER BY k.ID_Klasy;
END;
$$;

CREATE OR REPLACE PROCEDURE sp_aktualizuj_klase(
    p_id INT, p_nazwa VARCHAR, p_cena DECIMAL
) LANGUAGE plpgsql AS $$
BEGIN
    UPDATE Klasy_Pojazdow
    SET Nazwa_Klasy = COALESCE(p_nazwa, Nazwa_Klasy),
        Cena_Za_Dobe = COALESCE(p_cena, Cena_Za_Dobe)
    WHERE ID_Klasy = p_id;
END;
$$;

CREATE OR REPLACE PROCEDURE sp_usun_klase(p_id INT)
LANGUAGE plpgsql AS $$
BEGIN
    DELETE FROM Klasy_Pojazdow WHERE ID_Klasy = p_id;
END;
$$;

-- === 4. POJAZDY (ZAKTUALIZOWANE O NOWE POLA) ===

CREATE OR REPLACE PROCEDURE sp_dodaj_pojazd(
    p_id_klasy INT, p_marka VARCHAR, p_model VARCHAR, p_rok INT,
    p_nr_rej VARCHAR, p_przebieg INT, p_stan VARCHAR, p_status VARCHAR,
    p_wymaga_serwisu BOOLEAN DEFAULT FALSE, p_opis_usterki VARCHAR DEFAULT NULL
) LANGUAGE plpgsql AS $$
BEGIN
    IF EXISTS (SELECT 1 FROM Pojazdy WHERE Numer_Rejestracyjny = p_nr_rej) THEN
        RAISE EXCEPTION 'Błąd: Pojazd o numerze rejestracyjnym % już istnieje!', p_nr_rej;
    END IF;

    INSERT INTO Pojazdy (ID_Klasy, Marka, Model, Rok_Produkcji, Numer_Rejestracyjny, Przebieg, Stan_Techniczny, Status_Dostepnosci, Wymaga_Serwisu, Opis_Usterki)
    VALUES (p_id_klasy, p_marka, p_model, p_rok, p_nr_rej, p_przebieg, p_stan, p_status, p_wymaga_serwisu, p_opis_usterki);
END;
$$;

CREATE OR REPLACE FUNCTION fn_pobierz_pojazdy(p_id INT DEFAULT NULL)
RETURNS SETOF Pojazdy LANGUAGE plpgsql AS $$
BEGIN
    RETURN QUERY SELECT * FROM Pojazdy p WHERE p_id IS NULL OR p.ID_Pojazdu = p_id ORDER BY p.ID_Pojazdu;
END;
$$;

CREATE OR REPLACE PROCEDURE sp_aktualizuj_pojazd(
    p_id INT, p_id_klasy INT, p_marka VARCHAR, p_model VARCHAR, p_rok INT,
    p_nr_rej VARCHAR, p_przebieg INT, p_stan VARCHAR, p_status VARCHAR,
    p_wymaga_serwisu BOOLEAN, p_opis_usterki VARCHAR
) LANGUAGE plpgsql AS $$
BEGIN
    UPDATE Pojazdy
    SET ID_Klasy = COALESCE(p_id_klasy, ID_Klasy),
        Marka = COALESCE(p_marka, Marka),
        Model = COALESCE(p_model, Model),
        Rok_Produkcji = COALESCE(p_rok, Rok_Produkcji),
        Numer_Rejestracyjny = COALESCE(p_nr_rej, Numer_Rejestracyjny),
        Przebieg = COALESCE(p_przebieg, Przebieg),
        Stan_Techniczny = COALESCE(p_stan, Stan_Techniczny),
        Status_Dostepnosci = COALESCE(p_status, Status_Dostepnosci),
        Wymaga_Serwisu = COALESCE(p_wymaga_serwisu, Wymaga_Serwisu),
        Opis_Usterki = COALESCE(p_opis_usterki, Opis_Usterki)
    WHERE ID_Pojazdu = p_id;
END;
$$;

CREATE OR REPLACE PROCEDURE sp_usun_pojazd(p_id INT)
LANGUAGE plpgsql AS $$
BEGIN
    IF EXISTS (SELECT 1 FROM Rezerwacje WHERE ID_Pojazdu = p_id) THEN
        RAISE EXCEPTION 'Błąd: Nie można usunąć pojazdu, który ma historię rezerwacji!';
    END IF;
    DELETE FROM Pojazdy WHERE ID_Pojazdu = p_id;
END;
$$;

-- === 5. REZERWACJE ===

CREATE OR REPLACE PROCEDURE sp_dodaj_rezerwacje(
    p_id_klienta INT, p_id_pojazdu INT, p_id_pracownika INT,
    p_data_rez DATE, p_data_odb DATE, p_data_zwr DATE,
    p_miejsce VARCHAR, p_cena DECIMAL, p_status VARCHAR
) LANGUAGE plpgsql AS $$
DECLARE
    v_wymaga_serwisu BOOLEAN;
    v_opis_usterki TEXT;
BEGIN
    SELECT Wymaga_Serwisu, Opis_Usterki INTO v_wymaga_serwisu, v_opis_usterki
    FROM Pojazdy WHERE ID_Pojazdu = p_id_pojazdu;

    IF v_wymaga_serwisu THEN
        RAISE EXCEPTION 'BŁĄD: Nie można wydać pojazdu! Zgłoszona usterka: %', v_opis_usterki;
    END IF;

    INSERT INTO Rezerwacje (ID_Klienta, ID_Pojazdu, ID_Pracownika, Data_Rezerwacji, Data_Odbioru, Data_Zwrotu, Miejsce_Odbioru, Cena_Calkowita, Status_Rezerwacji)
    VALUES (p_id_klienta, p_id_pojazdu, p_id_pracownika, p_data_rez, p_data_odb, p_data_zwr, p_miejsce, p_cena, p_status);
END;
$$;

CREATE OR REPLACE FUNCTION fn_pobierz_rezerwacje(p_id INT DEFAULT NULL)
RETURNS SETOF Rezerwacje LANGUAGE plpgsql AS $$
BEGIN
    RETURN QUERY SELECT * FROM Rezerwacje r WHERE p_id IS NULL OR r.ID_Rezerwacji = p_id ORDER BY r.ID_Rezerwacji DESC;
END;
$$;

CREATE OR REPLACE PROCEDURE sp_aktualizuj_rezerwacje(
    p_id INT, p_id_klienta INT, p_id_pojazdu INT, p_id_pracownika INT,
    p_data_rez DATE, p_data_odb DATE, p_data_zwr DATE,
    p_miejsce VARCHAR, p_cena DECIMAL, p_status VARCHAR
) LANGUAGE plpgsql AS $$
BEGIN
    UPDATE Rezerwacje
    SET ID_Klienta = COALESCE(p_id_klienta, ID_Klienta),
        ID_Pojazdu = COALESCE(p_id_pojazdu, ID_Pojazdu),
        ID_Pracownika = COALESCE(p_id_pracownika, ID_Pracownika),
        Data_Rezerwacji = COALESCE(p_data_rez, Data_Rezerwacji),
        Data_Odbioru = COALESCE(p_data_odb, Data_Odbioru),
        Data_Zwrotu = COALESCE(p_data_zwr, Data_Zwrotu),
        Miejsce_Odbioru = COALESCE(p_miejsce, Miejsce_Odbioru),
        Cena_Calkowita = COALESCE(p_cena, Cena_Calkowita),
        Status_Rezerwacji = COALESCE(p_status, Status_Rezerwacji)
    WHERE ID_Rezerwacji = p_id;
END;
$$;

CREATE OR REPLACE PROCEDURE sp_usun_rezerwacje(p_id INT)
LANGUAGE plpgsql AS $$
BEGIN
    DELETE FROM Rezerwacje WHERE ID_Rezerwacji = p_id;
END;
$$;

-- === 6. USŁUGI I SERWISY ===

CREATE OR REPLACE PROCEDURE sp_dodaj_usluge(p_nazwa VARCHAR, p_cena DECIMAL) LANGUAGE plpgsql AS $$
BEGIN
    INSERT INTO Uslugi_Dodatkowe (Nazwa_Uslugi, Cena) VALUES (p_nazwa, p_cena);
END;
$$;

CREATE OR REPLACE FUNCTION fn_pobierz_uslugi(p_id INT DEFAULT NULL) RETURNS SETOF Uslugi_Dodatkowe LANGUAGE plpgsql AS $$
BEGIN
    RETURN QUERY SELECT * FROM Uslugi_Dodatkowe u WHERE p_id IS NULL OR u.ID_Uslugi = p_id ORDER BY u.ID_Uslugi;
END;
$$;

CREATE OR REPLACE PROCEDURE sp_dodaj_serwis(
    p_id_pojazdu INT, p_data DATE, p_opis VARCHAR, p_koszt DECIMAL, p_przebieg INT
) LANGUAGE plpgsql AS $$
BEGIN
    INSERT INTO Serwisy (ID_Pojazdu, Data_Serwisu, Opis, Koszt, Przebieg_W_Chwili_Serwisu)
    VALUES (p_id_pojazdu, p_data, p_opis, p_koszt, p_przebieg);
END;
$$;

CREATE OR REPLACE FUNCTION fn_pobierz_serwisy(p_id INT DEFAULT NULL)
RETURNS SETOF Serwisy LANGUAGE plpgsql AS $$
BEGIN
    RETURN QUERY SELECT * FROM Serwisy s WHERE p_id IS NULL OR s.ID_Serwisu = p_id ORDER BY s.Data_Serwisu DESC;
END;
$$;

---------------------------------------------------------------------------------
-- 4. -----ZAPYTANIA I RAPORTY (Wersja Zaawansowana)-----
---------------------------------------------------------------------------------

-- 1. Wyszukiwanie dostępnych pojazdów
CREATE OR REPLACE FUNCTION ZnajdzDostepnePojazdy(p_data_od DATE, p_data_do DATE, p_klasa_id INT DEFAULT NULL)
RETURNS TABLE (ID_Pojazdu INT, Marka VARCHAR, Model VARCHAR, Nr_Rej VARCHAR, Cena DECIMAL, Klasa VARCHAR) AS $$
BEGIN
    RETURN QUERY
    SELECT
        p.ID_Pojazdu, p.Marka, p.Model, p.Numer_Rejestracyjny,
        kp.Cena_Za_Dobe, kp.Nazwa_Klasy
    FROM Pojazdy p
    JOIN Klasy_Pojazdow kp ON p.ID_Klasy = kp.ID_Klasy
    WHERE p.Status_Dostepnosci != 'W serwisie'
      AND p.Wymaga_Serwisu = FALSE
      AND (p_klasa_id IS NULL OR p.ID_Klasy = p_klasa_id)
      AND NOT EXISTS (
          SELECT 1 FROM Rezerwacje r
          WHERE r.ID_Pojazdu = p.ID_Pojazdu
          AND r.Status_Rezerwacji IN ('Potwierdzona', 'W trakcie')
          AND daterange(r.Data_Odbioru, r.Data_Zwrotu, '[]') && daterange(p_data_od, p_data_do, '[]')
      );
END;
$$ LANGUAGE plpgsql;

-- 2. Raport finansowy (ZAAWANSOWANY: Trend MoM + Growth Rate)
CREATE OR REPLACE FUNCTION RaportPrzychodow(p_rok INT)
RETURNS TABLE (
    Miesiac TEXT,
    Przychod DECIMAL,
    Poprzedni_Miesiac DECIMAL,
    Zmiana_Procentowa TEXT,
    Udzial_W_Roku TEXT
) AS $$
DECLARE
    rec RECORD;
    v_roczna_suma DECIMAL;
    v_poprzedni_przychod DECIMAL := 0;
    v_aktualny_przychod DECIMAL;
    v_zmiana DECIMAL;
BEGIN
    SELECT SUM(Kwota_Calkowita) INTO v_roczna_suma
    FROM Platnosci
    WHERE EXTRACT(YEAR FROM Data_Platnosci) = p_rok
      AND Status_Platnosci = 'Zrealizowana';

    v_roczna_suma := COALESCE(v_roczna_suma, 1);

    FOR rec IN
        SELECT EXTRACT(MONTH FROM m)::INT as m_num, TO_CHAR(m, 'Month') as m_nazwa
        FROM generate_series(
            MAKE_DATE(p_rok, 1, 1),
            MAKE_DATE(p_rok, 12, 1),
            INTERVAL '1 month'
        ) m
    LOOP
        SELECT COALESCE(SUM(Kwota_Calkowita), 0) INTO v_aktualny_przychod
        FROM Platnosci
        WHERE EXTRACT(YEAR FROM Data_Platnosci) = p_rok
          AND EXTRACT(MONTH FROM Data_Platnosci) = rec.m_num
          AND Status_Platnosci = 'Zrealizowana';

        Miesiac := rec.m_nazwa;
        Przychod := v_aktualny_przychod;
        Poprzedni_Miesiac := v_poprzedni_przychod;

        IF v_poprzedni_przychod = 0 THEN
            Zmiana_Procentowa := '---';
        ELSE
            v_zmiana := ((v_aktualny_przychod - v_poprzedni_przychod) / v_poprzedni_przychod) * 100;
            Zmiana_Procentowa := ROUND(v_zmiana, 1) || '%';
        END IF;

        Udzial_W_Roku := ROUND((v_aktualny_przychod / v_roczna_suma * 100), 1) || '%';

        v_poprzedni_przychod := v_aktualny_przychod;

        RETURN NEXT;
    END LOOP;
END;
$$ LANGUAGE plpgsql;

-- 3. Ranking Klientów VIP
CREATE OR REPLACE FUNCTION RankingKlientowVIP(top_n INT)
RETURNS TABLE (
    Klient TEXT,
    Wydatki DECIMAL,
    RFM_Kod TEXT,
    Segment_Marketingowy TEXT
) AS $$
DECLARE
    rec RECORD;
    v_r_score INT;
    v_f_score INT;
    v_m_score INT;
    v_max_wydatki DECIMAL;
    v_max_wizyty INT;
BEGIN
    SELECT MAX(sum_wydatki), MAX(cnt_wizyty)
    INTO v_max_wydatki, v_max_wizyty
    FROM (
        SELECT SUM(p.Kwota_Calkowita) as sum_wydatki, COUNT(r.ID_Rezerwacji) as cnt_wizyty
        FROM Rezerwacje r JOIN Platnosci p ON r.ID_Rezerwacji = p.ID_Rezerwacji
        WHERE p.Status_Platnosci = 'Zrealizowana'
        GROUP BY r.ID_Klienta
    ) sub;

    v_max_wydatki := COALESCE(v_max_wydatki, 1);
    v_max_wizyty := COALESCE(v_max_wizyty, 1);

    FOR rec IN
        SELECT
            k.ID_Klienta,
            (k.Imie || ' ' || k.Nazwisko) as nazwa,
            MAX(r.Data_Rezerwacji) as ost_data,
            COUNT(r.ID_Rezerwacji) as wizyty,
            SUM(p.Kwota_Calkowita) as kwota
        FROM Klienci k
        JOIN Rezerwacje r ON k.ID_Klienta = r.ID_Klienta
        JOIN Platnosci p ON r.ID_Rezerwacji = p.ID_Rezerwacji
        WHERE p.Status_Platnosci = 'Zrealizowana'
        GROUP BY k.ID_Klienta
        ORDER BY kwota DESC
        LIMIT top_n
    LOOP
        v_m_score := CEIL((rec.kwota / v_max_wydatki) * 4);
        v_f_score := CEIL((rec.wizyty::DECIMAL / v_max_wizyty) * 4);

        IF rec.ost_data > CURRENT_DATE - INTERVAL '3 month' THEN v_r_score := 4;
        ELSIF rec.ost_data > CURRENT_DATE - INTERVAL '6 month' THEN v_r_score := 3;
        ELSIF rec.ost_data > CURRENT_DATE - INTERVAL '12 month' THEN v_r_score := 2;
        ELSE v_r_score := 1;
        END IF;

        Klient := rec.nazwa;
        Wydatki := rec.kwota;

        RFM_Kod := v_r_score::TEXT || v_f_score::TEXT || v_m_score::TEXT;

        IF v_m_score = 4 AND v_f_score >= 3 THEN Segment_Marketingowy := '💎 Absolutny Champion';
        ELSIF v_m_score >= 3 THEN Segment_Marketingowy := '💰 Wieloryb (Dużo wydaje)';
        ELSIF v_f_score >= 3 THEN Segment_Marketingowy := '🔄 Lojalny bywalec';
        ELSIF v_r_score = 1 THEN Segment_Marketingowy := '💤 Ryzyko odejścia';
        ELSE Segment_Marketingowy := '🙂 Standardowy';
        END IF;

        RETURN NEXT;
    END LOOP;
END;
$$ LANGUAGE plpgsql;
-- 4. Analiza przestojów
CREATE OR REPLACE FUNCTION AnalizaPrzestojow(min_dni_przerwy INT)
RETURNS TABLE (Pojazd VARCHAR, Data_Zwrotu DATE, Data_Nastepnego_Odbioru DATE, Dni_Przestoju INT) AS $$
DECLARE
    r RECORD;
BEGIN
    FOR r IN
        SELECT
            p.Marka || ' ' || p.Model AS auto,
            rez.Data_Zwrotu AS data_konca,
            LEAD(rez.Data_Odbioru) OVER (PARTITION BY p.ID_Pojazdu ORDER BY rez.Data_Odbioru) AS data_start_next
        FROM Pojazdy p
        JOIN Rezerwacje rez ON p.ID_Pojazdu = rez.ID_Pojazdu
        WHERE rez.Status_Rezerwacji != 'Anulowana'
    LOOP
        IF r.data_start_next IS NOT NULL THEN
            Dni_Przestoju := (r.data_start_next - r.data_konca);
            IF Dni_Przestoju >= min_dni_przerwy THEN
                Pojazd := r.auto;
                Data_Zwrotu := r.data_konca;
                Data_Nastepnego_Odbioru := r.data_start_next;
                RETURN NEXT;
            END IF;
        END IF;
    END LOOP;
END;
$$ LANGUAGE plpgsql;

-- 5. JSON Historii Klienta
CREATE OR REPLACE FUNCTION PobierzHistorieKlientaJSON(p_id_klienta INT)
RETURNS JSON AS $$
BEGIN
    RETURN (
        SELECT json_build_object(
            'klient_id', p_id_klienta,
            'imie_nazwisko', (SELECT Imie || ' ' || Nazwisko FROM Klienci WHERE ID_Klienta = p_id_klienta),
            'historia', COALESCE((
                SELECT json_agg(json_build_object(
                    'pojazd', p.Marka || ' ' || p.Model,
                    'termin', r.Data_Odbioru || ' do ' || r.Data_Zwrotu,
                    'koszt', r.Cena_Calkowita,
                    'status', r.Status_Rezerwacji
                ) ORDER BY r.Data_Odbioru DESC)
                FROM Rezerwacje r
                JOIN Pojazdy p ON r.ID_Pojazdu = p.ID_Pojazdu
                WHERE r.ID_Klienta = p_id_klienta
            ), '[]'::json)
        )
    );
END;
$$ LANGUAGE plpgsql;

-- 6. Obłożenie Roczne
CREATE OR REPLACE FUNCTION OblozenieRoczne(p_rok INT)
RETURNS TABLE (Dzien DATE, Liczba_Aut INT) AS $$
BEGIN
    RETURN QUERY
    SELECT
        kalendarz.data::DATE,
        COUNT(r.ID_Rezerwacji)::INT
    FROM generate_series(
        MAKE_DATE(p_rok, 1, 1),
        MAKE_DATE(p_rok, 12, 31),
        INTERVAL '1 day'
    ) AS kalendarz(data)
    LEFT JOIN Rezerwacje r ON
        r.Status_Rezerwacji != 'Anulowana'
        AND kalendarz.data BETWEEN r.Data_Odbioru AND r.Data_Zwrotu
    GROUP BY kalendarz.data
    ORDER BY kalendarz.data;
END;
$$ LANGUAGE plpgsql;

-- 7. Efektywność Pracowników
CREATE OR REPLACE FUNCTION EfektywnoscPracownikow()
RETURNS TABLE (Pracownik VARCHAR, Obrót DECIMAL, Ocena VARCHAR) AS $$
DECLARE
    v_srednia DECIMAL;
    rec RECORD;
BEGIN
    SELECT AVG(s.suma) INTO v_srednia FROM (SELECT SUM(Cena_Calkowita) as suma FROM Rezerwacje GROUP BY ID_Pracownika) s;

    FOR rec IN
        SELECT (p.Imie || ' ' || p.Nazwisko) as osoba, COALESCE(SUM(r.Cena_Calkowita),0) as total
        FROM Pracownicy p LEFT JOIN Rezerwacje r ON p.ID_Pracownika = r.ID_Pracownika
        GROUP BY p.ID_Pracownika ORDER BY total DESC
    LOOP
        Pracownik := rec.osoba;
        Obrót := rec.total;
        IF rec.total > (v_srednia * 1.2) THEN Ocena := '⭐ Lider Sprzedaży';
        ELSIF rec.total < (v_srednia * 0.5) THEN Ocena := '⚠️ Poniżej normy';
        ELSE Ocena := '✅ W normie';
        END IF;
        RETURN NEXT;
    END LOOP;
END;
$$ LANGUAGE plpgsql;

-- 8. Status Klientów (Pętla)
CREATE OR REPLACE FUNCTION StatusKlientow()
RETURNS TABLE (Klient VARCHAR, Dni_Temu INT, Status TEXT) AS $$
DECLARE
    rec RECORD;
    v_ostatni DATE;
    v_diff INT;
BEGIN
    FOR rec IN SELECT ID_Klienta, Imie, Nazwisko FROM Klienci LOOP
        SELECT MAX(Data_Zwrotu) INTO v_ostatni FROM Rezerwacje WHERE ID_Klienta = rec.ID_Klienta;
        Klient := rec.Imie || ' ' || rec.Nazwisko;

        IF v_ostatni IS NULL THEN
            Dni_Temu := NULL;
            Status := 'Nowy / Brak Historii';
        ELSE
            v_diff := (CURRENT_DATE - v_ostatni);
            Dni_Temu := v_diff;
            IF v_diff < 30 THEN Status := '🟢 Aktywny (Super)';
            ELSIF v_diff < 90 THEN Status := '🟡 Aktywny';
            ELSIF v_diff < 365 THEN Status := '🟠 Uśpiony';
            ELSE Status := '🔴 Utracony';
            END IF;
        END IF;
        RETURN NEXT;
    END LOOP;
END;
$$ LANGUAGE plpgsql;

-- 9. Prognoza Serwisowa
CREATE OR REPLACE FUNCTION PrognozaSerwisowa(limit_km_serwisu INT DEFAULT 15000)
RETURNS TABLE (Pojazd VARCHAR, Problem VARCHAR, Priorytet TEXT, Szacowana_Data DATE) AS $$
DECLARE
    rec RECORD;
BEGIN
    FOR rec IN
        SELECT
            p.ID_Pojazdu, p.Marka, p.Model, p.Przebieg, p.Wymaga_Serwisu, p.Opis_Usterki,
            COALESCE(MAX(s.Przebieg_W_Chwili_Serwisu), 0) as ost_serwis_km
        FROM Pojazdy p
        LEFT JOIN Serwisy s ON p.ID_Pojazdu = s.ID_Pojazdu
        WHERE p.Status_Dostepnosci != 'W serwisie'
        GROUP BY p.ID_Pojazdu
    LOOP
        Pojazd := rec.Marka || ' ' || rec.Model;
        Szacowana_Data := CURRENT_DATE;

        IF rec.Wymaga_Serwisu THEN
            Problem := '⚠️ ZGŁOSZENIE: ' || COALESCE(rec.Opis_Usterki, 'Brak opisu');
            Priorytet := 'WYSOKI (Awaria)';
            RETURN NEXT;
        ELSIF (rec.Przebieg - rec.ost_serwis_km) >= limit_km_serwisu THEN
            Problem := '🛢️ Wymiana oleju (Przebieg)';
            Priorytet := 'ŚREDNI';
            RETURN NEXT;
        ELSIF (rec.Przebieg - rec.ost_serwis_km) >= (limit_km_serwisu - 1000) THEN
            Problem := '⏳ Wkrótce przegląd';
            Priorytet := 'NISKI';
            RETURN NEXT;
        END IF;
    END LOOP;
END;
$$ LANGUAGE plpgsql;

-- Wrapper dla UI
CREATE OR REPLACE FUNCTION fn_pobierz_pojazdy_alert(limit_km INT)
RETURNS TABLE (Pojazd VARCHAR, Problem VARCHAR, Priorytet TEXT, Szacowana_Data DATE) AS $$
BEGIN
    RETURN QUERY SELECT * FROM PrognozaSerwisowa(limit_km);
END;
$$ LANGUAGE plpgsql;

-- 10. Szukaj Pojazdu
CREATE OR REPLACE FUNCTION SzukajPojazdu(fraza TEXT)
RETURNS SETOF Pojazdy AS $$
DECLARE
    r Pojazdy%ROWTYPE;
    v_clean TEXT;
    v_exact TEXT;
BEGIN
    v_exact := TRIM(fraza);
    v_clean := '%' || v_exact || '%';

    FOR r IN
        SELECT * FROM Pojazdy p
        WHERE p.Marka ILIKE v_clean
           OR p.Model ILIKE v_clean
           OR p.Numer_Rejestracyjny ILIKE v_clean
        ORDER BY
            CASE
                WHEN p.Numer_Rejestracyjny ILIKE v_exact THEN 0
                WHEN p.Marka ILIKE v_exact THEN 1
                WHEN p.Marka ILIKE (v_exact || '%') THEN 2
                ELSE 3
            END ASC,
            p.Marka, p.Model
    LOOP
        RETURN NEXT r;
    END LOOP;
END;
$$ LANGUAGE plpgsql;

---------------------------------------------------------------------------------
-- !!! FUNKCJE POMOCNICZE  !!!
---------------------------------------------------------------------------------

-- A. Statystyki Pulpitu
CREATE OR REPLACE FUNCTION fn_statystyki_pulpit()
RETURNS TABLE (Liczba_Pojazdow BIGINT, Liczba_Klientow BIGINT, Aktywne_Rezerwacje BIGINT) AS $$
BEGIN
    RETURN QUERY SELECT
        (SELECT COUNT(*) FROM Pojazdy),
        (SELECT COUNT(*) FROM Klienci),
        (SELECT COUNT(*) FROM Rezerwacje WHERE Status_Rezerwacji IN ('W trakcie', 'Potwierdzona'));
END;
$$ LANGUAGE plpgsql;

-- B. Znajdź ID Klienta po PESEL
CREATE OR REPLACE FUNCTION fn_znajdz_klienta_pesel(p_pesel VARCHAR)
RETURNS INT AS $$
DECLARE v_id INT;
BEGIN
    SELECT ID_Klienta INTO v_id FROM Klienci WHERE PESEL = p_pesel;
    RETURN v_id;
END;
$$ LANGUAGE plpgsql;
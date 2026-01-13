---------------------------------------------------------------------------------
-- 1. CZYSZCZENIE (DROP EVERYTHING)
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
DROP FUNCTION IF EXISTS EfektywnoscPracownikow CASCADE;
DROP FUNCTION IF EXISTS StatusKlientow CASCADE;
DROP FUNCTION IF EXISTS PrognozaSerwisowa CASCADE;
DROP FUNCTION IF EXISTS SzukajPojazdu CASCADE;

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
    Status_Dostepnosci VARCHAR(20) CHECK (Status_Dostepnosci IN ('Dostępny', 'Wypożyczony', 'W serwisie'))
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
    Status_Rezerwacji VARCHAR(20) CHECK (Status_Rezerwacji IN ('Potwierdzona', 'Anulowana', 'Zakończona')),
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
    IF p_id IS NOT NULL AND NOT EXISTS (SELECT 1 FROM Klienci k WHERE k.ID_Klienta = p_id) THEN
        RAISE EXCEPTION 'Błąd: Nie znaleziono klienta o ID %', p_id;
    END IF;

    RETURN QUERY
    SELECT k.ID_Klienta, k.Imie, k.Nazwisko, k.PESEL, k.Numer_Prawa_Jazdy, k.Telefon, k.Email, k.Adres
    FROM Klienci k
    WHERE p_id IS NULL OR k.ID_Klienta = p_id
    ORDER BY k.ID_Klienta;
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

-- 1D. Usuń Klienta
CREATE OR REPLACE PROCEDURE sp_usun_klienta(p_id INT)
LANGUAGE plpgsql AS $$
BEGIN
    IF EXISTS (SELECT 1 FROM Rezerwacje WHERE ID_Klienta = p_id AND Status_Rezerwacji = 'Potwierdzona') THEN
        RAISE EXCEPTION 'Błąd: Nie można usunąć klienta, który ma aktywne rezerwacje!';
    END IF;

    DELETE FROM Klienci WHERE ID_Klienta = p_id;

    IF NOT FOUND THEN
        RAISE EXCEPTION 'Nie znaleziono klienta o ID %', p_id;
    END IF;
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
    IF p_id IS NOT NULL AND NOT EXISTS (SELECT 1 FROM Pracownicy p WHERE p.ID_Pracownika = p_id) THEN
        RAISE EXCEPTION 'Błąd: Nie znaleziono pracownika o ID %', p_id;
    END IF;

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

    IF NOT FOUND THEN
        RAISE EXCEPTION 'Nie znaleziono pracownika o ID %', p_id;
    END IF;
END;
$$;

-- 2D. Usuń Pracownika
CREATE OR REPLACE PROCEDURE sp_usun_pracownika(p_id INT)
LANGUAGE plpgsql AS $$
BEGIN
    UPDATE Rezerwacje SET ID_Pracownika = NULL WHERE ID_Pracownika = p_id;

    DELETE FROM Pracownicy WHERE ID_Pracownika = p_id;

    IF NOT FOUND THEN
        RAISE EXCEPTION 'Nie znaleziono pracownika o ID %', p_id;
    END IF;
END;
$$;

-- === 3. KLASY POJAZDÓW ===

-- 3A. Dodaj Klasę
CREATE OR REPLACE PROCEDURE sp_dodaj_klase(
    p_nazwa VARCHAR, p_cena DECIMAL
) LANGUAGE plpgsql AS $$
BEGIN
    IF EXISTS (SELECT 1 FROM Klasy_Pojazdow WHERE Nazwa_Klasy = p_nazwa) THEN
        RAISE EXCEPTION 'Błąd: Klasa pojazdu "%" już istnieje!', p_nazwa;
    END IF;

    INSERT INTO Klasy_Pojazdow (Nazwa_Klasy, Cena_Za_Dobe) VALUES (p_nazwa, p_cena);
END;
$$;

-- 3B. Pobierz Klasy
CREATE OR REPLACE FUNCTION fn_pobierz_klasy(p_id INT DEFAULT NULL)
RETURNS SETOF Klasy_Pojazdow LANGUAGE plpgsql AS $$
BEGIN
    IF p_id IS NOT NULL AND NOT EXISTS (SELECT 1 FROM Klasy_Pojazdow k WHERE k.ID_Klasy = p_id) THEN
        RAISE EXCEPTION 'Błąd: Nie znaleziono klasy pojazdu o ID %', p_id;
    END IF;

    RETURN QUERY SELECT * FROM Klasy_Pojazdow k WHERE p_id IS NULL OR k.ID_Klasy = p_id ORDER BY k.ID_Klasy;
END;
$$;

-- 3C. Aktualizuj Klasę
CREATE OR REPLACE PROCEDURE sp_aktualizuj_klase(
    p_id INT, p_nazwa VARCHAR, p_cena DECIMAL
) LANGUAGE plpgsql AS $$
BEGIN
    IF p_nazwa IS NOT NULL AND EXISTS (SELECT 1 FROM Klasy_Pojazdow WHERE Nazwa_Klasy = p_nazwa AND ID_Klasy != p_id) THEN
        RAISE EXCEPTION 'Błąd: Nazwa klasy "%" jest już zajęta!', p_nazwa;
    END IF;

    UPDATE Klasy_Pojazdow
    SET Nazwa_Klasy = COALESCE(p_nazwa, Nazwa_Klasy),
        Cena_Za_Dobe = COALESCE(p_cena, Cena_Za_Dobe)
    WHERE ID_Klasy = p_id;

    IF NOT FOUND THEN
        RAISE EXCEPTION 'Nie znaleziono klasy o ID %', p_id;
    END IF;
END;
$$;

-- 3D. Usuń Klasę
CREATE OR REPLACE PROCEDURE sp_usun_klase(p_id INT)
LANGUAGE plpgsql AS $$
BEGIN
    IF EXISTS (SELECT 1 FROM Pojazdy WHERE ID_Klasy = p_id) THEN
        RAISE EXCEPTION 'Błąd: Nie można usunąć klasy, do której przypisane są pojazdy!';
    END IF;

    DELETE FROM Klasy_Pojazdow WHERE ID_Klasy = p_id;

    IF NOT FOUND THEN
        RAISE EXCEPTION 'Nie znaleziono klasy o ID %', p_id;
    END IF;
END;
$$;

-- === 4. POJAZDY ===

-- 4A. Dodaj Pojazd
CREATE OR REPLACE PROCEDURE sp_dodaj_pojazd(
    p_id_klasy INT, p_marka VARCHAR, p_model VARCHAR, p_rok INT,
    p_nr_rej VARCHAR, p_przebieg INT, p_stan VARCHAR, p_status VARCHAR
) LANGUAGE plpgsql AS $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM Klasy_Pojazdow WHERE ID_Klasy = p_id_klasy) THEN
        RAISE EXCEPTION 'Błąd: Podana klasa pojazdu (ID: %) nie istnieje!', p_id_klasy;
    END IF;
    IF EXISTS (SELECT 1 FROM Pojazdy WHERE Numer_Rejestracyjny = p_nr_rej) THEN
        RAISE EXCEPTION 'Błąd: Pojazd o numerze rejestracyjnym % już istnieje!', p_nr_rej;
    END IF;

    INSERT INTO Pojazdy (ID_Klasy, Marka, Model, Rok_Produkcji, Numer_Rejestracyjny, Przebieg, Stan_Techniczny, Status_Dostepnosci)
    VALUES (p_id_klasy, p_marka, p_model, p_rok, p_nr_rej, p_przebieg, p_stan, p_status);
END;
$$;

-- 4B. Pobierz Pojazdy
CREATE OR REPLACE FUNCTION fn_pobierz_pojazdy(p_id INT DEFAULT NULL)
RETURNS SETOF Pojazdy LANGUAGE plpgsql AS $$
BEGIN
    IF p_id IS NOT NULL AND NOT EXISTS (SELECT 1 FROM Pojazdy p WHERE p.ID_Pojazdu = p_id) THEN
        RAISE EXCEPTION 'Błąd: Nie znaleziono pojazdu o ID %', p_id;
    END IF;

    RETURN QUERY SELECT * FROM Pojazdy p WHERE p_id IS NULL OR p.ID_Pojazdu = p_id ORDER BY p.ID_Pojazdu;
END;
$$;

-- 4C. Aktualizuj Pojazd
CREATE OR REPLACE PROCEDURE sp_aktualizuj_pojazd(
    p_id INT, p_id_klasy INT, p_marka VARCHAR, p_model VARCHAR, p_rok INT,
    p_nr_rej VARCHAR, p_przebieg INT, p_stan VARCHAR, p_status VARCHAR
) LANGUAGE plpgsql AS $$
BEGIN
    IF p_nr_rej IS NOT NULL AND EXISTS (SELECT 1 FROM Pojazdy WHERE Numer_Rejestracyjny = p_nr_rej AND ID_Pojazdu != p_id) THEN
        RAISE EXCEPTION 'Błąd: Nr rejestracyjny % jest już zajęty przez inny pojazd!', p_nr_rej;
    END IF;

    UPDATE Pojazdy
    SET ID_Klasy = COALESCE(p_id_klasy, ID_Klasy),
        Marka = COALESCE(p_marka, Marka),
        Model = COALESCE(p_model, Model),
        Rok_Produkcji = COALESCE(p_rok, Rok_Produkcji),
        Numer_Rejestracyjny = COALESCE(p_nr_rej, Numer_Rejestracyjny),
        Przebieg = COALESCE(p_przebieg, Przebieg),
        Stan_Techniczny = COALESCE(p_stan, Stan_Techniczny),
        Status_Dostepnosci = COALESCE(p_status, Status_Dostepnosci)
    WHERE ID_Pojazdu = p_id;

    IF NOT FOUND THEN
        RAISE EXCEPTION 'Nie znaleziono pojazdu o ID %', p_id;
    END IF;
END;
$$;

-- 4D. Usuń Pojazd
CREATE OR REPLACE PROCEDURE sp_usun_pojazd(p_id INT)
LANGUAGE plpgsql AS $$
BEGIN
    IF EXISTS (SELECT 1 FROM Rezerwacje WHERE ID_Pojazdu = p_id) THEN
        RAISE EXCEPTION 'Błąd: Nie można usunąć pojazdu, który ma historię rezerwacji!';
    END IF;

    DELETE FROM Pojazdy WHERE ID_Pojazdu = p_id;

    IF NOT FOUND THEN
        RAISE EXCEPTION 'Nie znaleziono pojazdu o ID %', p_id;
    END IF;
END;
$$;

-- === 5. REZERWACJE ===

-- 5A. Dodaj Rezerwację
CREATE OR REPLACE PROCEDURE sp_dodaj_rezerwacje(
    p_id_klienta INT, p_id_pojazdu INT, p_id_pracownika INT,
    p_data_rez DATE, p_data_odb DATE, p_data_zwr DATE,
    p_miejsce VARCHAR, p_cena DECIMAL, p_status VARCHAR
) LANGUAGE plpgsql AS $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM Klienci WHERE ID_Klienta = p_id_klienta) THEN
        RAISE EXCEPTION 'Błąd: Klient o ID % nie istnieje!', p_id_klienta;
    END IF;
    IF NOT EXISTS (SELECT 1 FROM Pojazdy WHERE ID_Pojazdu = p_id_pojazdu) THEN
        RAISE EXCEPTION 'Błąd: Pojazd o ID % nie istnieje!', p_id_pojazdu;
    END IF;

    IF p_data_zwr < p_data_odb THEN
        RAISE EXCEPTION 'Błąd: Data zwrotu nie może być wcześniejsza niż data odbioru!';
    END IF;

    INSERT INTO Rezerwacje (ID_Klienta, ID_Pojazdu, ID_Pracownika, Data_Rezerwacji, Data_Odbioru, Data_Zwrotu, Miejsce_Odbioru, Cena_Calkowita, Status_Rezerwacji)
    VALUES (p_id_klienta, p_id_pojazdu, p_id_pracownika, p_data_rez, p_data_odb, p_data_zwr, p_miejsce, p_cena, p_status);
END;
$$;

-- 5B. Pobierz Rezerwacje
CREATE OR REPLACE FUNCTION fn_pobierz_rezerwacje(p_id INT DEFAULT NULL)
RETURNS SETOF Rezerwacje LANGUAGE plpgsql AS $$
BEGIN
    IF p_id IS NOT NULL AND NOT EXISTS (SELECT 1 FROM Rezerwacje r WHERE r.ID_Rezerwacji = p_id) THEN
        RAISE EXCEPTION 'Błąd: Nie znaleziono rezerwacji o ID %', p_id;
    END IF;

    RETURN QUERY SELECT * FROM Rezerwacje r WHERE p_id IS NULL OR r.ID_Rezerwacji = p_id ORDER BY r.ID_Rezerwacji DESC;
END;
$$;

-- 5C. Aktualizuj Rezerwację
CREATE OR REPLACE PROCEDURE sp_aktualizuj_rezerwacje(
    p_id INT, p_id_klienta INT, p_id_pojazdu INT, p_id_pracownika INT,
    p_data_rez DATE, p_data_odb DATE, p_data_zwr DATE,
    p_miejsce VARCHAR, p_cena DECIMAL, p_status VARCHAR
) LANGUAGE plpgsql AS $$
BEGIN
    IF p_data_odb IS NOT NULL AND p_data_zwr IS NOT NULL AND p_data_zwr < p_data_odb THEN
        RAISE EXCEPTION 'Błąd: Data zwrotu nie może być wcześniejsza niż data odbioru!';
    END IF;

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

    IF NOT FOUND THEN
        RAISE EXCEPTION 'Nie znaleziono rezerwacji o ID %', p_id;
    END IF;
END;
$$;

-- 5D. Usuń Rezerwację
CREATE OR REPLACE PROCEDURE sp_usun_rezerwacje(p_id INT)
LANGUAGE plpgsql AS $$
BEGIN
    DELETE FROM Rezerwacje WHERE ID_Rezerwacji = p_id;

    IF NOT FOUND THEN
        RAISE EXCEPTION 'Nie znaleziono rezerwacji o ID %', p_id;
    END IF;
END;
$$;

-- === 6. USŁUGI DODATKOWE ===

-- 6A. Dodaj Usługę
CREATE OR REPLACE PROCEDURE sp_dodaj_usluge(
    p_nazwa VARCHAR, p_cena DECIMAL
) LANGUAGE plpgsql AS $$
BEGIN
    INSERT INTO Uslugi_Dodatkowe (Nazwa_Uslugi, Cena) VALUES (p_nazwa, p_cena);
END;
$$;

-- 6B. Pobierz Usługi
CREATE OR REPLACE FUNCTION fn_pobierz_uslugi(p_id INT DEFAULT NULL)
RETURNS SETOF Uslugi_Dodatkowe LANGUAGE plpgsql AS $$
BEGIN
    IF p_id IS NOT NULL AND NOT EXISTS (SELECT 1 FROM Uslugi_Dodatkowe u WHERE u.ID_Uslugi = p_id) THEN
        RAISE EXCEPTION 'Błąd: Nie znaleziono usługi dodatkowej o ID %', p_id;
    END IF;

    RETURN QUERY SELECT * FROM Uslugi_Dodatkowe u WHERE p_id IS NULL OR u.ID_Uslugi = p_id ORDER BY u.ID_Uslugi;
END;
$$;

-- 6C. Aktualizuj Usługę
CREATE OR REPLACE PROCEDURE sp_aktualizuj_usluge(
    p_id INT, p_nazwa VARCHAR, p_cena DECIMAL
) LANGUAGE plpgsql AS $$
BEGIN
    UPDATE Uslugi_Dodatkowe
    SET Nazwa_Uslugi = COALESCE(p_nazwa, Nazwa_Uslugi),
        Cena = COALESCE(p_cena, Cena)
    WHERE ID_Uslugi = p_id;

    IF NOT FOUND THEN
        RAISE EXCEPTION 'Nie znaleziono usługi o ID %', p_id;
    END IF;
END;
$$;

-- 6D. Usuń Usługę
CREATE OR REPLACE PROCEDURE sp_usun_usluge(p_id INT)
LANGUAGE plpgsql AS $$
BEGIN
    DELETE FROM Uslugi_Dodatkowe WHERE ID_Uslugi = p_id;

    IF NOT FOUND THEN
        RAISE EXCEPTION 'Nie znaleziono usługi o ID %', p_id;
    END IF;
END;
$$;

-- === 7. REZERWACJE_USŁUGI ===

-- 7A. Dodaj Usługę do Rezerwacji
CREATE OR REPLACE PROCEDURE sp_dodaj_usluge_do_rezerwacji(
    p_id_rez INT, p_id_uslugi INT
) LANGUAGE plpgsql AS $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM Rezerwacje WHERE ID_Rezerwacji = p_id_rez) THEN
        RAISE EXCEPTION 'Błąd: Rezerwacja o ID % nie istnieje!', p_id_rez;
    END IF;
    IF NOT EXISTS (SELECT 1 FROM Uslugi_Dodatkowe WHERE ID_Uslugi = p_id_uslugi) THEN
        RAISE EXCEPTION 'Błąd: Usługa o ID % nie istnieje!', p_id_uslugi;
    END IF;
    IF EXISTS (SELECT 1 FROM Rezerwacje_Uslugi WHERE ID_Rezerwacji = p_id_rez AND ID_Uslugi = p_id_uslugi) THEN
        RAISE EXCEPTION 'Błąd: Ta usługa jest już przypisana do tej rezerwacji!';
    END IF;

    INSERT INTO Rezerwacje_Uslugi (ID_Rezerwacji, ID_Uslugi) VALUES (p_id_rez, p_id_uslugi);
END;
$$;

-- 7B. Pobierz Usługi Rezerwacji
CREATE OR REPLACE FUNCTION fn_pobierz_uslugi_rezerwacji(p_id_rez INT)
RETURNS TABLE (ID_Przypisania INT, RezerwacjaID INT, Nazwa_Uslugi VARCHAR, Cena DECIMAL)
LANGUAGE plpgsql AS $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM Rezerwacje r WHERE r.ID_Rezerwacji = p_id_rez) THEN
        RAISE EXCEPTION 'Błąd: Rezerwacja o ID % nie istnieje, nie można pobrać usług.', p_id_rez;
    END IF;

    RETURN QUERY
    SELECT ru.ID_Rezerwacji_Uslugi, ru.ID_Rezerwacji, u.Nazwa_Uslugi, u.Cena
    FROM Rezerwacje_Uslugi ru
    JOIN Uslugi_Dodatkowe u ON ru.ID_Uslugi = u.ID_Uslugi
    WHERE ru.ID_Rezerwacji = p_id_rez;
END;
$$;

-- 7C. Aktualizuj Przypisanie Usługi
CREATE OR REPLACE PROCEDURE sp_aktualizuj_usluge_rezerwacji(
    p_id_rez_uslugi INT, p_nowe_id_uslugi INT
) LANGUAGE plpgsql AS $$
BEGIN
    UPDATE Rezerwacje_Uslugi
    SET ID_Uslugi = p_nowe_id_uslugi
    WHERE ID_Rezerwacji_Uslugi = p_id_rez_uslugi;

    IF NOT FOUND THEN
        RAISE EXCEPTION 'Nie znaleziono przypisania usługi o ID %', p_id_rez_uslugi;
    END IF;
END;
$$;

-- 7D. Usuń Usługę z Rezerwacji
CREATE OR REPLACE PROCEDURE sp_usun_usluge_z_rezerwacji(p_id_rez_uslugi INT)
LANGUAGE plpgsql AS $$
BEGIN
    DELETE FROM Rezerwacje_Uslugi WHERE ID_Rezerwacji_Uslugi = p_id_rez_uslugi;

    IF NOT FOUND THEN
        RAISE EXCEPTION 'Nie znaleziono przypisania usługi o ID %', p_id_rez_uslugi;
    END IF;
END;
$$;

-- === 8. PŁATNOŚCI ===

-- 8A. Dodaj Płatność
CREATE OR REPLACE PROCEDURE sp_dodaj_platnosc(
    p_id_rez INT, p_kwota DECIMAL, p_data DATE,
    p_forma VARCHAR, p_status VARCHAR, p_faktura VARCHAR
) LANGUAGE plpgsql AS $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM Rezerwacje WHERE ID_Rezerwacji = p_id_rez) THEN
        RAISE EXCEPTION 'Błąd: Rezerwacja o ID % nie istnieje!', p_id_rez;
    END IF;

    INSERT INTO Platnosci (ID_Rezerwacji, Kwota_Calkowita, Data_Platnosci, Forma_Platnosci, Status_Platnosci, Numer_Faktury)
    VALUES (p_id_rez, p_kwota, p_data, p_forma, p_status, p_faktura);
END;
$$;

-- 8B. Pobierz Płatności
CREATE OR REPLACE FUNCTION fn_pobierz_platnosci(p_id INT DEFAULT NULL)
RETURNS SETOF Platnosci LANGUAGE plpgsql AS $$
BEGIN
    IF p_id IS NOT NULL AND NOT EXISTS (SELECT 1 FROM Platnosci pl WHERE pl.ID_Platnosci = p_id) THEN
        RAISE EXCEPTION 'Błąd: Nie znaleziono płatności o ID %', p_id;
    END IF;

    RETURN QUERY SELECT * FROM Platnosci pl WHERE p_id IS NULL OR pl.ID_Platnosci = p_id ORDER BY pl.ID_Platnosci;
END;
$$;

-- 8C. Aktualizuj Płatność
CREATE OR REPLACE PROCEDURE sp_aktualizuj_platnosc(
    p_id INT, p_kwota DECIMAL, p_data DATE,
    p_forma VARCHAR, p_status VARCHAR, p_faktura VARCHAR
) LANGUAGE plpgsql AS $$
BEGIN
    UPDATE Platnosci
    SET Kwota_Calkowita = COALESCE(p_kwota, Kwota_Calkowita),
        Data_Platnosci = COALESCE(p_data, Data_Platnosci),
        Forma_Platnosci = COALESCE(p_forma, Forma_Platnosci),
        Status_Platnosci = COALESCE(p_status, Status_Platnosci),
        Numer_Faktury = COALESCE(p_faktura, Numer_Faktury)
    WHERE ID_Platnosci = p_id;

    IF NOT FOUND THEN
        RAISE EXCEPTION 'Nie znaleziono płatności o ID %', p_id;
    END IF;
END;
$$;

-- 8D. Usuń Płatność
CREATE OR REPLACE PROCEDURE sp_usun_platnosc(p_id INT)
LANGUAGE plpgsql AS $$
BEGIN
    DELETE FROM Platnosci WHERE ID_Platnosci = p_id;

    IF NOT FOUND THEN
        RAISE EXCEPTION 'Nie znaleziono płatności o ID %', p_id;
    END IF;
END;
$$;

-- === 9. SERWISY ===

-- 9A. Dodaj Serwis
CREATE OR REPLACE PROCEDURE sp_dodaj_serwis(
    p_id_pojazdu INT, p_data DATE, p_opis VARCHAR, p_koszt DECIMAL, p_przebieg INT
) LANGUAGE plpgsql AS $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM Pojazdy WHERE ID_Pojazdu = p_id_pojazdu) THEN
        RAISE EXCEPTION 'Błąd: Pojazd o ID % nie istnieje!', p_id_pojazdu;
    END IF;

    INSERT INTO Serwisy (ID_Pojazdu, Data_Serwisu, Opis, Koszt, Przebieg_W_Chwili_Serwisu)
    VALUES (p_id_pojazdu, p_data, p_opis, p_koszt, p_przebieg);
END;
$$;

-- 9B. Pobierz Serwisy
CREATE OR REPLACE FUNCTION fn_pobierz_serwisy(p_id INT DEFAULT NULL)
RETURNS SETOF Serwisy LANGUAGE plpgsql AS $$
BEGIN
    IF p_id IS NOT NULL AND NOT EXISTS (SELECT 1 FROM Serwisy s WHERE s.ID_Serwisu = p_id) THEN
        RAISE EXCEPTION 'Błąd: Nie znaleziono wpisu serwisowego o ID %', p_id;
    END IF;

    RETURN QUERY
    SELECT * FROM Serwisy s
    WHERE p_id IS NULL OR s.ID_Serwisu = p_id
    ORDER BY s.Data_Serwisu DESC;
END;
$$;

-- 9C. Aktualizuj Serwis
CREATE OR REPLACE PROCEDURE sp_aktualizuj_serwis(
    p_id INT, p_id_pojazdu INT, p_data DATE, p_opis VARCHAR, p_koszt DECIMAL, p_przebieg INT
) LANGUAGE plpgsql AS $$
BEGIN
    UPDATE Serwisy
    SET ID_Pojazdu = COALESCE(p_id_pojazdu, ID_Pojazdu),
        Data_Serwisu = COALESCE(p_data, Data_Serwisu),
        Opis = COALESCE(p_opis, Opis),
        Koszt = COALESCE(p_koszt, Koszt),
        Przebieg_W_Chwili_Serwisu = COALESCE(p_przebieg, Przebieg_W_Chwili_Serwisu)
    WHERE ID_Serwisu = p_id;

    IF NOT FOUND THEN
        RAISE EXCEPTION 'Nie znaleziono wpisu serwisowego o ID %', p_id;
    END IF;
END;
$$;

-- 9D. Usuń Serwis
CREATE OR REPLACE PROCEDURE sp_usun_serwis(p_id INT)
LANGUAGE plpgsql AS $$
BEGIN
    DELETE FROM Serwisy WHERE ID_Serwisu = p_id;

    IF NOT FOUND THEN
        RAISE EXCEPTION 'Nie znaleziono wpisu serwisowego o ID %', p_id;
    END IF;
END;
$$;

---------------------------------------------------------------------------------
-- 4. -----ZAPYTANIA-----
---------------------------------------------------------------------------------

-- 1. Wyszukiwanie dostępnych pojazdów
CREATE OR REPLACE FUNCTION ZnajdzDostepnePojazdy(p_data_od DATE, p_data_do DATE, p_klasa_id INT DEFAULT NULL)
RETURNS TABLE (ID_Pojazdu INT, Marka VARCHAR, Model VARCHAR, Nr_Rej VARCHAR, Cena DECIMAL, Klasa VARCHAR) AS $$
BEGIN
    RETURN QUERY
    SELECT
        p.ID_Pojazdu,
        p.Marka,
        p.Model,
        p.Numer_Rejestracyjny,
        k.Cena_Za_Dobe,
        k.Nazwa_Klasy
    FROM Pojazdy p
    JOIN Klasy_Pojazdow k ON p.ID_Klasy = k.ID_Klasy
    LEFT JOIN Serwisy s ON p.ID_Pojazdu = s.ID_Pojazdu
    WHERE p.Status_Dostepnosci != 'W serwisie'
      AND (p_klasa_id IS NULL OR p.ID_Klasy = p_klasa_id)
      AND NOT EXISTS (
          SELECT 1 FROM Rezerwacje r
          WHERE r.ID_Pojazdu = p.ID_Pojazdu
          AND r.Status_Rezerwacji != 'Anulowana'
          AND daterange(r.Data_Odbioru, r.Data_Zwrotu, '[]') && daterange(p_data_od, p_data_do, '[]')
      )
    GROUP BY p.ID_Pojazdu, p.Marka, p.Model, p.Numer_Rejestracyjny, k.Cena_Za_Dobe, k.Nazwa_Klasy
    HAVING (p.Przebieg - COALESCE(MAX(s.Przebieg_W_Chwili_Serwisu), 0)) < 15000;
END;
$$ LANGUAGE plpgsql;

-- 2. Raport finansowy
CREATE OR REPLACE FUNCTION RaportPrzychodow(p_rok INT)
RETURNS TABLE (Miesiac TEXT, Gotowka DECIMAL, Karta DECIMAL, Przelew DECIMAL, Razem DECIMAL, Narastajaco DECIMAL) AS $$
DECLARE
    v_miesiac INT;
    v_gotowka DECIMAL;
    v_karta DECIMAL;
    v_przelew DECIMAL;
    v_total DECIMAL;
    v_narastajaco DECIMAL := 0;
BEGIN
    CREATE TEMP TABLE IF NOT EXISTS TempRaport (
        m_id INT, m_nazwa TEXT, g DECIMAL, k DECIMAL, p DECIMAL, r DECIMAL, n DECIMAL
    ) ON COMMIT DROP;

    DELETE FROM TempRaport;

    FOR v_miesiac IN 1..12 LOOP
        SELECT COALESCE(SUM(Kwota_Calkowita) FILTER (WHERE Forma_Platnosci = 'Gotówka'), 0),
               COALESCE(SUM(Kwota_Calkowita) FILTER (WHERE Forma_Platnosci = 'Karta'), 0),
               COALESCE(SUM(Kwota_Calkowita) FILTER (WHERE Forma_Platnosci = 'Przelew'), 0)
        INTO v_gotowka, v_karta, v_przelew
        FROM Platnosci
        WHERE EXTRACT(YEAR FROM Data_Platnosci) = p_rok
          AND EXTRACT(MONTH FROM Data_Platnosci) = v_miesiac
          AND Status_Platnosci = 'Zrealizowana';

        v_total := v_gotowka + v_karta + v_przelew;
        v_narastajaco := v_narastajaco + v_total;

        INSERT INTO TempRaport VALUES (
            v_miesiac,
            TO_CHAR(MAKE_DATE(p_rok, v_miesiac, 1), 'MM - Month'),
            v_gotowka, v_karta, v_przelew, v_total, v_narastajaco
        );
    END LOOP;

    RETURN QUERY SELECT m_nazwa, g, k, p, r, n FROM TempRaport ORDER BY m_id;
END;
$$ LANGUAGE plpgsql;

-- 3. Ranking Klientów VIP
CREATE OR REPLACE FUNCTION RankingKlientowVIP(top_n INT)
RETURNS TABLE (Pozycja INT, Klient VARCHAR, Ile_Rezerwacji BIGINT, Wydano DECIMAL, Status_VIP VARCHAR) AS $$
DECLARE
    r RECORD;
    v_rank INT := 0;
BEGIN
    FOR r IN
        SELECT (k.Imie || ' ' || k.Nazwisko)::VARCHAR as w_klient,
               COUNT(rez.ID_Rezerwacji) as w_ile,
               COALESCE(SUM(p.Kwota_Calkowita), 0) as w_hajs
        FROM Klienci k
        JOIN Rezerwacje rez ON k.ID_Klienta = rez.ID_Klienta
        JOIN Platnosci p ON rez.ID_Rezerwacji = p.ID_Rezerwacji
        WHERE p.Status_Platnosci = 'Zrealizowana'
        GROUP BY k.ID_Klienta, k.Imie, k.Nazwisko
        ORDER BY w_hajs DESC
    LOOP
        v_rank := v_rank + 1;
        IF v_rank > top_n THEN EXIT; END IF;

        IF r.w_hajs > 5000 THEN Status_VIP := 'Platynowy';
        ELSIF r.w_hajs > 2000 THEN Status_VIP := 'Złoty';
        ELSE Status_VIP := 'Srebrny';
        END IF;

        Pozycja := v_rank;
        Klient := r.w_klient;
        Ile_Rezerwacji := r.w_ile;
        Wydano := r.w_hajs;
        RETURN NEXT;
    END LOOP;
END;
$$ LANGUAGE plpgsql;

-- 4. Analiza przestojów floty
CREATE OR REPLACE FUNCTION AnalizaPrzestojow(min_dni_przerwy INT)
RETURNS TABLE (Pojazd VARCHAR, Data_Zwrotu DATE, Data_Nastepnego_Odbioru DATE, Dni_Przestoju INT) AS $$
DECLARE
    cur_rez CURSOR FOR
        SELECT p.ID_Pojazdu, (p.Marka || ' ' || p.Model) as auto, r.Data_Zwrotu, r.Data_Odbioru
        FROM Pojazdy p JOIN Rezerwacje r ON p.ID_Pojazdu = r.ID_Pojazdu
        WHERE r.Status_Rezerwacji != 'Anulowana' ORDER BY p.ID_Pojazdu, r.Data_Odbioru;

    prev_row RECORD;
    curr_row RECORD;
BEGIN
    OPEN cur_rez;
    FETCH cur_rez INTO prev_row;

    LOOP
        FETCH cur_rez INTO curr_row;
        EXIT WHEN NOT FOUND;

        IF prev_row.ID_Pojazdu = curr_row.ID_Pojazdu THEN
            Dni_Przestoju := (curr_row.Data_Odbioru - prev_row.Data_Zwrotu);

            IF Dni_Przestoju >= min_dni_przerwy THEN
                Pojazd := prev_row.auto;
                Data_Zwrotu := prev_row.Data_Zwrotu;
                Data_Nastepnego_Odbioru := curr_row.Data_Odbioru;
                RETURN NEXT;
            END IF;
        END IF;

        prev_row := curr_row;
    END LOOP;
    CLOSE cur_rez;
END;
$$ LANGUAGE plpgsql;

-- 5. Eksport historii klienta do JSON
CREATE OR REPLACE FUNCTION PobierzHistorieKlientaJSON(p_id_klienta INT)
RETURNS JSON AS $$
DECLARE
    wynik JSON;
BEGIN
    SELECT json_build_object(
        'klient_id', p_id_klienta,
        'dane_osobowe', (k.Imie || ' ' || k.Nazwisko),
        'historia_rezerwacji', COALESCE(json_agg(json_build_object(
            'samochod', (p.Marka || ' ' || p.Model),
            'termin', (r.Data_Odbioru || ' do ' || r.Data_Zwrotu),
            'koszt', (r.Cena_Calkowita || ' PLN'),
            'status', r.Status_Rezerwacji
        ) ORDER BY r.Data_Odbioru DESC), '[]'::json)
    ) INTO wynik
    FROM Klienci k
    LEFT JOIN Rezerwacje r ON k.ID_Klienta = r.ID_Klienta
    LEFT JOIN Pojazdy p ON r.ID_Pojazdu = p.ID_Pojazdu
    WHERE k.ID_Klienta = p_id_klienta
    GROUP BY k.ID_Klienta;
    RETURN wynik;
END;
$$ LANGUAGE plpgsql;

-- 6. Kalendarz obłożenia
CREATE OR REPLACE FUNCTION OblozenieMiesieczne(p_rok INT, p_miesiac INT)
RETURNS TABLE (Dzien DATE, Liczba_Aut INT) AS $$
DECLARE
    v_dzien DATE;
    v_koniec_miesiaca DATE;
BEGIN
    v_dzien := MAKE_DATE(p_rok, p_miesiac, 1);
    v_koniec_miesiaca := (v_dzien + INTERVAL '1 month' - INTERVAL '1 day')::DATE;

    WHILE v_dzien <= v_koniec_miesiaca LOOP
        SELECT COUNT(*) INTO Liczba_Aut
        FROM Rezerwacje
        WHERE Status_Rezerwacji != 'Anulowana'
          AND v_dzien BETWEEN Data_Odbioru AND Data_Zwrotu;

        Dzien := v_dzien;
        RETURN NEXT;

        v_dzien := v_dzien + 1;
    END LOOP;
END;
$$ LANGUAGE plpgsql;

-- 7. Efektywność pracowników
CREATE OR REPLACE FUNCTION EfektywnoscPracownikow()
RETURNS TABLE (Pracownik VARCHAR, Obrót DECIMAL, Ocena VARCHAR) AS $$
DECLARE
    v_srednia DECIMAL;
    rec RECORD;
BEGIN
    SELECT AVG(suma) INTO v_srednia FROM (
        SELECT SUM(Cena_Calkowita) as suma FROM Rezerwacje GROUP BY ID_Pracownika
    ) s;

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

-- 8. Status lojalnościowy klientów
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

-- 9. Prognoza serwisowa
CREATE OR REPLACE FUNCTION PrognozaSerwisowa(limit_km_serwisu INT DEFAULT 15000)
RETURNS TABLE (Pojazd VARCHAR, Przebieg INT, Km_Do_Serwisu INT, Status TEXT) AS $$
DECLARE
    r RECORD;
    v_ostatni_serwis INT;
    v_roznica INT;
BEGIN
    FOR r IN SELECT p.ID_Pojazdu, p.Marka, p.Model, p.Przebieg FROM Pojazdy p LOOP
        SELECT COALESCE(MAX(s.Przebieg_W_Chwili_Serwisu), 0) INTO v_ostatni_serwis
        FROM Serwisy s WHERE s.ID_Pojazdu = r.ID_Pojazdu;

        v_roznica := r.Przebieg - v_ostatni_serwis;
        Km_Do_Serwisu := limit_km_serwisu - v_roznica;
        Pojazd := r.Marka || ' ' || r.Model;
        Przebieg := r.Przebieg;

        IF Km_Do_Serwisu <= 0 THEN Status := '❗ SERWIS NATYCHMIAST';
        ELSIF Km_Do_Serwisu < 1000 THEN Status := '⚠️ Blisko serwisu';
        ELSE Status := '✅ OK';
        END IF;

        RETURN NEXT;
    END LOOP;
END;
$$ LANGUAGE plpgsql;

-- 10. Wyszukiwarka pojazdów
CREATE OR REPLACE FUNCTION SzukajPojazdu(fraza TEXT)
RETURNS SETOF Pojazdy AS $$
DECLARE
    v_clean_fraza TEXT;
BEGIN
    v_clean_fraza := TRIM(fraza);
    v_clean_fraza := '%' || v_clean_fraza || '%';

    RETURN QUERY
    SELECT * FROM Pojazdy p
    WHERE p.Marka ILIKE v_clean_fraza
       OR p.Model ILIKE v_clean_fraza
       OR p.Numer_Rejestracyjny ILIKE v_clean_fraza;
END;
$$ LANGUAGE plpgsql;
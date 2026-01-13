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
    Login VARCHAR(50) UNIQUE NOT NULL, -- Dodane pod aplikację
    Haslo VARCHAR(50) NOT NULL         -- Dodane pod aplikację
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
    ID_Rezerwacji_Uslugi SERIAL PRIMARY KEY, -- Dodany klucz główny dla łatwiejszego usuwania
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
-- 3. -----CRUDY-----
---------------------------------------------------------------------------------

-- === 1. KLIENCI ===

-- 1A. Dodaj Klienta
CREATE OR REPLACE PROCEDURE sp_dodaj_klienta(
    p_imie VARCHAR, p_nazwisko VARCHAR, p_pesel VARCHAR,
    p_nr_prawa VARCHAR, p_telefon VARCHAR, p_email VARCHAR, p_adres VARCHAR
) LANGUAGE plpgsql AS $$
BEGIN
    IF EXISTS (SELECT 1 FROM Klienci WHERE PESEL = p_pesel) THEN
        RAISE EXCEPTION 'Błąd: Klient o podanym numerze PESEL już istnieje!';
    END IF;
    INSERT INTO Klienci (Imie, Nazwisko, PESEL, Numer_Prawa_Jazdy, Telefon, Email, Adres)
    VALUES (p_imie, p_nazwisko, p_pesel, p_nr_prawa, p_telefon, p_email, p_adres);
END;
$$;

-- 1B. Pobierz Klientów
CREATE OR REPLACE FUNCTION fn_pobierz_klientow(p_id INT DEFAULT NULL)
RETURNS TABLE (ID_Klienta INT, Imie VARCHAR, Nazwisko VARCHAR, PESEL VARCHAR, Nr_Prawa_Jazdy VARCHAR, Telefon VARCHAR, Email VARCHAR, Adres VARCHAR)
LANGUAGE plpgsql AS $$
BEGIN
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
    UPDATE Klienci
    SET Imie = COALESCE(p_imie, Imie),
        Nazwisko = COALESCE(p_nazwisko, Nazwisko),
        PESEL = COALESCE(p_pesel, PESEL),
        Numer_Prawa_Jazdy = COALESCE(p_nr_prawa, Numer_Prawa_Jazdy),
        Telefon = COALESCE(p_telefon, Telefon),
        Email = COALESCE(p_email, Email),
        Adres = COALESCE(p_adres, Adres)
    WHERE ID_Klienta = p_id;
    IF NOT FOUND THEN RAISE EXCEPTION 'Nie znaleziono klienta o ID %', p_id; END IF;
END;
$$;

-- 1D. Usuń Klienta
CREATE OR REPLACE PROCEDURE sp_usun_klienta(p_id INT)
LANGUAGE plpgsql AS $$
BEGIN
    DELETE FROM Klienci WHERE ID_Klienta = p_id;
    IF NOT FOUND THEN RAISE EXCEPTION 'Nie znaleziono klienta o ID %', p_id; END IF;
END;
$$;

-- === 2. PRACOWNICY ===

-- 2A. Dodaj Pracownika (z loginem i hasłem)
CREATE OR REPLACE PROCEDURE sp_dodaj_pracownika(
    p_imie VARCHAR, p_nazwisko VARCHAR, p_stanowisko VARCHAR,
    p_login VARCHAR DEFAULT NULL, p_haslo VARCHAR DEFAULT NULL
) LANGUAGE plpgsql AS $$
BEGIN
    INSERT INTO Pracownicy (Imie, Nazwisko, Stanowisko, Login, Haslo)
    VALUES (p_imie, p_nazwisko, p_stanowisko, p_login, p_haslo);
END;
$$;

-- 2B. Pobierz Pracowników
CREATE OR REPLACE FUNCTION fn_pobierz_pracownikow(p_id INT DEFAULT NULL)
RETURNS TABLE (ID_Pracownika INT, Imie VARCHAR, Nazwisko VARCHAR, Stanowisko VARCHAR)
LANGUAGE plpgsql AS $$
BEGIN
    RETURN QUERY
    SELECT p.ID_Pracownika, p.Imie, p.Nazwisko, p.Stanowisko
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
    IF NOT FOUND THEN RAISE EXCEPTION 'Nie znaleziono pracownika o ID %', p_id; END IF;
END;
$$;

-- 2D. Usuń Pracownika (Z zabezpieczeniem historii)
CREATE OR REPLACE PROCEDURE sp_usun_pracownika(p_id INT)
LANGUAGE plpgsql AS $$
BEGIN
    UPDATE Rezerwacje SET ID_Pracownika = NULL WHERE ID_Pracownika = p_id;
    DELETE FROM Pracownicy WHERE ID_Pracownika = p_id;
    IF NOT FOUND THEN RAISE EXCEPTION 'Nie znaleziono pracownika o ID %', p_id; END IF;
END;
$$;

-- === 3. KLASY POJAZDÓW ===

-- 3A. Dodaj Klasę
CREATE OR REPLACE PROCEDURE sp_dodaj_klase(
    p_nazwa VARCHAR, p_cena DECIMAL
) LANGUAGE plpgsql AS $$
BEGIN
    INSERT INTO Klasy_Pojazdow (Nazwa_Klasy, Cena_Za_Dobe) VALUES (p_nazwa, p_cena);
END;
$$;

-- 3B. Pobierz Klasy
CREATE OR REPLACE FUNCTION fn_pobierz_klasy(p_id INT DEFAULT NULL)
RETURNS SETOF Klasy_Pojazdow LANGUAGE plpgsql AS $$
BEGIN
    RETURN QUERY SELECT * FROM Klasy_Pojazdow WHERE p_id IS NULL OR ID_Klasy = p_id ORDER BY ID_Klasy;
END;
$$;

-- 3C. Aktualizuj Klasę
CREATE OR REPLACE PROCEDURE sp_aktualizuj_klase(
    p_id INT, p_nazwa VARCHAR, p_cena DECIMAL
) LANGUAGE plpgsql AS $$
BEGIN
    UPDATE Klasy_Pojazdow
    SET Nazwa_Klasy = COALESCE(p_nazwa, Nazwa_Klasy),
        Cena_Za_Dobe = COALESCE(p_cena, Cena_Za_Dobe)
    WHERE ID_Klasy = p_id;
    IF NOT FOUND THEN RAISE EXCEPTION 'Nie znaleziono klasy o ID %', p_id; END IF;
END;
$$;

-- 3D. Usuń Klasę
CREATE OR REPLACE PROCEDURE sp_usun_klase(p_id INT)
LANGUAGE plpgsql AS $$
BEGIN
    DELETE FROM Klasy_Pojazdow WHERE ID_Klasy = p_id;
    IF NOT FOUND THEN RAISE EXCEPTION 'Nie znaleziono klasy o ID %', p_id; END IF;
END;
$$;

-- === 4. POJAZDY ===

-- 4A. Dodaj Pojazd
CREATE OR REPLACE PROCEDURE sp_dodaj_pojazd(
    p_id_klasy INT, p_marka VARCHAR, p_model VARCHAR, p_rok INT,
    p_nr_rej VARCHAR, p_przebieg INT, p_stan VARCHAR, p_status VARCHAR
) LANGUAGE plpgsql AS $$
BEGIN
    INSERT INTO Pojazdy (ID_Klasy, Marka, Model, Rok_Produkcji, Numer_Rejestracyjny, Przebieg, Stan_Techniczny, Status_Dostepnosci)
    VALUES (p_id_klasy, p_marka, p_model, p_rok, p_nr_rej, p_przebieg, p_stan, p_status);
END;
$$;

-- 4B. Pobierz Pojazdy
CREATE OR REPLACE FUNCTION fn_pobierz_pojazdy(p_id INT DEFAULT NULL)
RETURNS SETOF Pojazdy LANGUAGE plpgsql AS $$
BEGIN
    RETURN QUERY SELECT * FROM Pojazdy WHERE p_id IS NULL OR ID_Pojazdu = p_id ORDER BY ID_Pojazdu;
END;
$$;

-- 4C. Aktualizuj Pojazd
CREATE OR REPLACE PROCEDURE sp_aktualizuj_pojazd(
    p_id INT, p_id_klasy INT, p_marka VARCHAR, p_model VARCHAR, p_rok INT,
    p_nr_rej VARCHAR, p_przebieg INT, p_stan VARCHAR, p_status VARCHAR
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
        Status_Dostepnosci = COALESCE(p_status, Status_Dostepnosci)
    WHERE ID_Pojazdu = p_id;
    IF NOT FOUND THEN RAISE EXCEPTION 'Nie znaleziono pojazdu o ID %', p_id; END IF;
END;
$$;

-- 4D. Usuń Pojazd
CREATE OR REPLACE PROCEDURE sp_usun_pojazd(p_id INT)
LANGUAGE plpgsql AS $$
BEGIN
    DELETE FROM Pojazdy WHERE ID_Pojazdu = p_id;
    IF NOT FOUND THEN RAISE EXCEPTION 'Nie znaleziono pojazdu o ID %', p_id; END IF;
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
    INSERT INTO Rezerwacje (ID_Klienta, ID_Pojazdu, ID_Pracownika, Data_Rezerwacji, Data_Odbioru, Data_Zwrotu, Miejsce_Odbioru, Cena_Calkowita, Status_Rezerwacji)
    VALUES (p_id_klienta, p_id_pojazdu, p_id_pracownika, p_data_rez, p_data_odb, p_data_zwr, p_miejsce, p_cena, p_status);
END;
$$;

-- 5B. Pobierz Rezerwacje
CREATE OR REPLACE FUNCTION fn_pobierz_rezerwacje(p_id INT DEFAULT NULL)
RETURNS SETOF Rezerwacje LANGUAGE plpgsql AS $$
BEGIN
    RETURN QUERY SELECT * FROM Rezerwacje WHERE p_id IS NULL OR ID_Rezerwacji = p_id ORDER BY ID_Rezerwacji DESC;
END;
$$;

-- 5C. Aktualizuj Rezerwację
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
    IF NOT FOUND THEN RAISE EXCEPTION 'Nie znaleziono rezerwacji o ID %', p_id; END IF;
END;
$$;

-- 5D. Usuń Rezerwację
CREATE OR REPLACE PROCEDURE sp_usun_rezerwacje(p_id INT)
LANGUAGE plpgsql AS $$
BEGIN
    DELETE FROM Rezerwacje WHERE ID_Rezerwacji = p_id;
    IF NOT FOUND THEN RAISE EXCEPTION 'Nie znaleziono rezerwacji o ID %', p_id; END IF;
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
    RETURN QUERY SELECT * FROM Uslugi_Dodatkowe WHERE p_id IS NULL OR ID_Uslugi = p_id ORDER BY ID_Uslugi;
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
    IF NOT FOUND THEN RAISE EXCEPTION 'Nie znaleziono usługi o ID %', p_id; END IF;
END;
$$;

-- 6D. Usuń Usługę
CREATE OR REPLACE PROCEDURE sp_usun_usluge(p_id INT)
LANGUAGE plpgsql AS $$
BEGIN
    DELETE FROM Uslugi_Dodatkowe WHERE ID_Uslugi = p_id;
    IF NOT FOUND THEN RAISE EXCEPTION 'Nie znaleziono usługi o ID %', p_id; END IF;
END;
$$;

-- === 7. REZERWACJE_USŁUGI (ŁĄCZNIK) ===

-- 7A. Dodaj Usługę do Rezerwacji
CREATE OR REPLACE PROCEDURE sp_dodaj_usluge_do_rezerwacji(
    p_id_rez INT, p_id_uslugi INT
) LANGUAGE plpgsql AS $$
BEGIN
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
    IF NOT FOUND THEN RAISE EXCEPTION 'Nie znaleziono przypisania usługi o ID %', p_id_rez_uslugi; END IF;
END;
$$;

-- 7D. Usuń Usługę z Rezerwacji
CREATE OR REPLACE PROCEDURE sp_usun_usluge_z_rezerwacji(p_id_rez_uslugi INT)
LANGUAGE plpgsql AS $$
BEGIN
    DELETE FROM Rezerwacje_Uslugi WHERE ID_Rezerwacji_Uslugi = p_id_rez_uslugi;
    IF NOT FOUND THEN RAISE EXCEPTION 'Nie znaleziono przypisania usługi o ID %', p_id_rez_uslugi; END IF;
END;
$$;

-- === 8. PŁATNOŚCI ===

-- 8A. Dodaj Płatność
CREATE OR REPLACE PROCEDURE sp_dodaj_platnosc(
    p_id_rez INT, p_kwota DECIMAL, p_data DATE,
    p_forma VARCHAR, p_status VARCHAR, p_faktura VARCHAR
) LANGUAGE plpgsql AS $$
BEGIN
    INSERT INTO Platnosci (ID_Rezerwacji, Kwota_Calkowita, Data_Platnosci, Forma_Platnosci, Status_Platnosci, Numer_Faktury)
    VALUES (p_id_rez, p_kwota, p_data, p_forma, p_status, p_faktura);
END;
$$;

-- 8B. Pobierz Płatności
CREATE OR REPLACE FUNCTION fn_pobierz_platnosci(p_id INT DEFAULT NULL)
RETURNS SETOF Platnosci LANGUAGE plpgsql AS $$
BEGIN
    RETURN QUERY SELECT * FROM Platnosci WHERE p_id IS NULL OR ID_Platnosci = p_id ORDER BY ID_Platnosci;
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
    IF NOT FOUND THEN RAISE EXCEPTION 'Nie znaleziono płatności o ID %', p_id; END IF;
END;
$$;

-- 8D. Usuń Płatność
CREATE OR REPLACE PROCEDURE sp_usun_platnosc(p_id INT)
LANGUAGE plpgsql AS $$
BEGIN
    DELETE FROM Platnosci WHERE ID_Platnosci = p_id;
    IF NOT FOUND THEN RAISE EXCEPTION 'Nie znaleziono płatności o ID %', p_id; END IF;
END;
$$;

-- === 9. SERWISY ===

-- 9A. Dodaj Serwis
CREATE OR REPLACE PROCEDURE sp_dodaj_serwis(
    p_id_pojazdu INT, p_data DATE, p_opis VARCHAR, p_koszt DECIMAL, p_przebieg INT
) LANGUAGE plpgsql AS $$
BEGIN
    INSERT INTO Serwisy (ID_Pojazdu, Data_Serwisu, Opis, Koszt, Przebieg_W_Chwili_Serwisu)
    VALUES (p_id_pojazdu, p_data, p_opis, p_koszt, p_przebieg);
END;
$$;

-- 9B. Pobierz Serwisy
CREATE OR REPLACE FUNCTION fn_pobierz_serwisy(p_id INT DEFAULT NULL)
RETURNS SETOF Serwisy LANGUAGE plpgsql AS $$
BEGIN
    RETURN QUERY
    SELECT * FROM Serwisy
    WHERE p_id IS NULL OR ID_Serwisu = p_id
    ORDER BY Data_Serwisu DESC;
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
    IF NOT FOUND THEN RAISE EXCEPTION 'Nie znaleziono wpisu serwisowego o ID %', p_id; END IF;
END;
$$;

-- 9D. Usuń Serwis
CREATE OR REPLACE PROCEDURE sp_usun_serwis(p_id INT)
LANGUAGE plpgsql AS $$
BEGIN
    DELETE FROM Serwisy WHERE ID_Serwisu = p_id;
    IF NOT FOUND THEN RAISE EXCEPTION 'Nie znaleziono wpisu serwisowego o ID %', p_id; END IF;
END;
$$;


---------------------------------------------------------------------------------
-- 4. -----ZAPYTANIA----- (PROBLEMOWE / ALGORYTMICZNE)
-- 10 Funkcji Zaawansowanych
---------------------------------------------------------------------------------

-- 1. Wyszukiwanie dostępnych pojazdów (Daterange + Intersect)
CREATE OR REPLACE FUNCTION ZnajdzDostepnePojazdy(p_data_od DATE, p_data_do DATE, p_klasa_id INT DEFAULT NULL)
RETURNS TABLE (ID_Pojazdu INT, Marka VARCHAR, Model VARCHAR, Nr_Rej VARCHAR, Cena DECIMAL, Klasa VARCHAR) AS $$
BEGIN
    RETURN QUERY
    SELECT p.ID_Pojazdu, p.Marka, p.Model, p.Numer_Rejestracyjny, k.Cena_Za_Dobe, k.Nazwa_Klasy
    FROM Pojazdy p
    JOIN Klasy_Pojazdow k ON p.ID_Klasy = k.ID_Klasy
    WHERE p.Status_Dostepnosci != 'W serwisie'
      AND (p_klasa_id IS NULL OR p.ID_Klasy = p_klasa_id)
      AND NOT EXISTS (
          SELECT 1 FROM Rezerwacje r
          WHERE r.ID_Pojazdu = p.ID_Pojazdu
          AND r.Status_Rezerwacji != 'Anulowana'
          AND daterange(r.Data_Odbioru, r.Data_Zwrotu, '[]') && daterange(p_data_od, p_data_do, '[]')
      );
END;
$$ LANGUAGE plpgsql;

-- 2. Raport finansowy (Suma narastająca)
CREATE OR REPLACE FUNCTION RaportPrzychodow(p_rok INT)
RETURNS TABLE (Miesiac TEXT, Gotowka DECIMAL, Karta DECIMAL, Przelew DECIMAL, Razem DECIMAL, Narastajaco DECIMAL) AS $$
BEGIN
    RETURN QUERY
    WITH Dane AS (
        SELECT
            TO_CHAR(p.Data_Platnosci, 'Month') as w_m_txt,
            EXTRACT(MONTH FROM p.Data_Platnosci) as w_m_num,
            COALESCE(SUM(Kwota_Calkowita) FILTER (WHERE Forma_Platnosci = 'Gotówka'), 0) as w_gotowka,
            COALESCE(SUM(Kwota_Calkowita) FILTER (WHERE Forma_Platnosci = 'Karta'), 0) as w_karta,
            COALESCE(SUM(Kwota_Calkowita) FILTER (WHERE Forma_Platnosci = 'Przelew'), 0) as w_przelew,
            SUM(Kwota_Calkowita) as w_razem
        FROM Platnosci p
        WHERE EXTRACT(YEAR FROM p.Data_Platnosci) = p_rok AND p.Status_Platnosci = 'Zrealizowana'
        GROUP BY 1, 2
    )
    SELECT w_m_txt::TEXT, w_gotowka, w_karta, w_przelew, w_razem, SUM(w_razem) OVER (ORDER BY w_m_num)::DECIMAL
    FROM Dane ORDER BY w_m_num;
END;
$$ LANGUAGE plpgsql;

-- 3. Ranking Klientów VIP (DENSE_RANK)
CREATE OR REPLACE FUNCTION RankingKlientowVIP(top_n INT)
RETURNS TABLE (Pozycja BIGINT, Klient VARCHAR, Ile_Rezerwacji BIGINT, Wydano DECIMAL) AS $$
BEGIN
    RETURN QUERY
    WITH Rank AS (
        SELECT (k.Imie || ' ' || k.Nazwisko)::VARCHAR as w_klient,
               COUNT(r.ID_Rezerwacji) as w_ile,
               SUM(p.Kwota_Calkowita) as w_hajs,
               DENSE_RANK() OVER (ORDER BY SUM(p.Kwota_Calkowita) DESC) as w_poz
        FROM Klienci k
        JOIN Rezerwacje r ON k.ID_Klienta = r.ID_Klienta
        JOIN Platnosci p ON r.ID_Rezerwacji = p.ID_Rezerwacji
        WHERE p.Status_Platnosci = 'Zrealizowana'
        GROUP BY k.ID_Klienta, k.Imie, k.Nazwisko
    )
    SELECT w_poz, w_klient, w_ile, w_hajs FROM Rank WHERE w_poz <= top_n;
END;
$$ LANGUAGE plpgsql;

-- 4. Analiza przestojów floty (LEAD)
CREATE OR REPLACE FUNCTION AnalizaPrzestojow(min_dni_przerwy INT)
RETURNS TABLE (Pojazd VARCHAR, Data_Zwrotu DATE, Data_Nastepnego_Odbioru DATE, Dni_Przestoju INT) AS $$
BEGIN
    RETURN QUERY
    WITH Luki AS (
        SELECT (p.Marka || ' ' || p.Model)::VARCHAR as w_auto,
               r.Data_Zwrotu as w_data_zwrotu,
               LEAD(r.Data_Odbioru) OVER (PARTITION BY p.ID_Pojazdu ORDER BY r.Data_Odbioru) as w_next_start
        FROM Pojazdy p
        JOIN Rezerwacje r ON p.ID_Pojazdu = r.ID_Pojazdu
        WHERE r.Status_Rezerwacji != 'Anulowana'
    )
    SELECT w_auto, w_data_zwrotu, w_next_start, (w_next_start - w_data_zwrotu)::INT
    FROM Luki
    WHERE (w_next_start - w_data_zwrotu) >= min_dni_przerwy;
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

-- 6. Kalendarz obłożenia (Generate Series)
CREATE OR REPLACE FUNCTION OblozenieMiesieczne(p_rok INT, p_miesiac INT)
RETURNS TABLE (Dzien DATE, Liczba_Aut INT) AS $$
BEGIN
    RETURN QUERY
    SELECT kalendarz::DATE, COUNT(r.ID_Rezerwacji)::INT
    FROM generate_series(
        MAKE_DATE(p_rok, p_miesiac, 1),
        (MAKE_DATE(p_rok, p_miesiac, 1) + INTERVAL '1 month' - INTERVAL '1 day'),
        '1 day'
    ) as kalendarz
    LEFT JOIN Rezerwacje r ON kalendarz BETWEEN r.Data_Odbioru AND r.Data_Zwrotu
        AND r.Status_Rezerwacji != 'Anulowana'
    GROUP BY kalendarz ORDER BY kalendarz;
END;
$$ LANGUAGE plpgsql;

-- 7. Efektywność pracowników
CREATE OR REPLACE FUNCTION EfektywnoscPracownikow()
RETURNS TABLE (Pracownik VARCHAR, Obrót DECIMAL, Srednia_Firmy DECIMAL, Wynik_Proc DECIMAL) AS $$
BEGIN
    RETURN QUERY
    WITH Stats AS (
        SELECT (pr.Imie || ' ' || pr.Nazwisko)::VARCHAR as osoba,
               COALESCE(SUM(r.Cena_Calkowita), 0) as obrot
        FROM Pracownicy pr
        LEFT JOIN Rezerwacje r ON pr.ID_Pracownika = r.ID_Pracownika
        GROUP BY pr.ID_Pracownika
    )
    SELECT osoba, obrot, AVG(obrot) OVER ()::DECIMAL(10,2), (obrot / NULLIF(AVG(obrot) OVER (), 0) * 100)::DECIMAL(5,2)
    FROM Stats ORDER BY obrot DESC;
END;
$$ LANGUAGE plpgsql;

-- 8. Status lojalnościowy klientów
CREATE OR REPLACE FUNCTION StatusKlientow()
RETURNS TABLE (Klient VARCHAR, Ostatni_Wynajem DATE, Dni_Temu INT, Status TEXT) AS $$
BEGIN
    RETURN QUERY
    SELECT (k.Imie || ' ' || k.Nazwisko)::VARCHAR, MAX(r.Data_Zwrotu), (CURRENT_DATE - MAX(r.Data_Zwrotu))::INT,
           CASE
               WHEN MAX(r.Data_Zwrotu) IS NULL THEN 'Nowy / Brak historii'
               WHEN (CURRENT_DATE - MAX(r.Data_Zwrotu)) < 90 THEN 'Aktywny'
               WHEN (CURRENT_DATE - MAX(r.Data_Zwrotu)) BETWEEN 90 AND 365 THEN 'Uśpiony'
               ELSE 'Utracony'
           END
    FROM Klienci k
    LEFT JOIN Rezerwacje r ON k.ID_Klienta = r.ID_Klienta
    GROUP BY k.ID_Klienta ORDER BY MAX(r.Data_Zwrotu) DESC NULLS LAST;
END;
$$ LANGUAGE plpgsql;

-- 9. Prognoza serwisowa
CREATE OR REPLACE FUNCTION PrognozaSerwisowa(limit_km_serwisu INT DEFAULT 15000)
RETURNS TABLE (Pojazd VARCHAR, Przebieg INT, Km_Do_Serwisu INT, Status TEXT) AS $$
BEGIN
    RETURN QUERY
    SELECT (p.Marka || ' ' || p.Model)::VARCHAR, p.Przebieg,
           (limit_km_serwisu - (p.Przebieg - COALESCE(MAX(s.Przebieg_W_Chwili_Serwisu), 0)))::INT as pozostalo,
           CASE
               WHEN (p.Przebieg - COALESCE(MAX(s.Przebieg_W_Chwili_Serwisu), 0)) >= limit_km_serwisu THEN '❗ SERWIS NATYCHMIAST'
               WHEN (p.Przebieg - COALESCE(MAX(s.Przebieg_W_Chwili_Serwisu), 0)) >= (limit_km_serwisu * 0.9) THEN '⚠️ Blisko serwisu'
               ELSE '✅ OK'
           END
    FROM Pojazdy p LEFT JOIN Serwisy s ON p.ID_Pojazdu = s.ID_Pojazdu GROUP BY p.ID_Pojazdu;
END;
$$ LANGUAGE plpgsql;

-- 10. Wyszukiwarka pojazdów
CREATE OR REPLACE FUNCTION SzukajPojazdu(fraza TEXT)
RETURNS SETOF Pojazdy AS $$
BEGIN
    RETURN QUERY
    SELECT * FROM Pojazdy p
    WHERE p.Marka ILIKE '%' || fraza || '%' OR p.Model ILIKE '%' || fraza || '%' OR p.Numer_Rejestracyjny ILIKE '%' || fraza || '%';
END;
$$ LANGUAGE plpgsql;
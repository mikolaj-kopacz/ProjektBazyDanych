DROP PROCEDURE IF EXISTS sp_dodaj_klienta CASCADE;
DROP PROCEDURE IF EXISTS sp_usun_klienta CASCADE;
DROP PROCEDURE IF EXISTS sp_dodaj_rezerwacje CASCADE;
DROP PROCEDURE IF EXISTS sp_dodaj_pracownika CASCADE;
DROP PROCEDURE IF EXISTS sp_usun_pracownika CASCADE;
DROP FUNCTION IF EXISTS fn_pobierz_klientow CASCADE;
DROP FUNCTION IF EXISTS fn_pobierz_klasy CASCADE;
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

DROP TABLE IF EXISTS Platnosci CASCADE;
DROP TABLE IF EXISTS Rezerwacje_Uslugi CASCADE;
DROP TABLE IF EXISTS Uslugi_Dodatkowe CASCADE;
DROP TABLE IF EXISTS Serwisy CASCADE;
DROP TABLE IF EXISTS Rezerwacje CASCADE;
DROP TABLE IF EXISTS Pojazdy CASCADE;
DROP TABLE IF EXISTS Klienci CASCADE;
DROP TABLE IF EXISTS Pracownicy CASCADE;
DROP TABLE IF EXISTS Klasy_Pojazdow CASCADE;

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
    ID_Rezerwacji INT REFERENCES Rezerwacje(ID_Rezerwacji),
    ID_Uslugi INT REFERENCES Uslugi_Dodatkowe(ID_Uslugi),
    PRIMARY KEY (ID_Rezerwacji, ID_Uslugi)
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

CREATE OR REPLACE PROCEDURE sp_dodaj_klienta(
    p_imie VARCHAR, p_nazwisko VARCHAR, p_pesel VARCHAR,
    p_nr_prawa VARCHAR, p_telefon VARCHAR, p_email VARCHAR, p_adres TEXT
) LANGUAGE plpgsql AS $$
BEGIN
    INSERT INTO Klienci (Imie, Nazwisko, PESEL, Numer_Prawa_Jazdy, Telefon, Email, Adres)
    VALUES (p_imie, p_nazwisko, p_pesel, p_nr_prawa, p_telefon, p_email, p_adres);
END;
$$;

CREATE OR REPLACE PROCEDURE sp_usun_klienta(p_id_klienta INT)
LANGUAGE plpgsql AS $$
BEGIN
    DELETE FROM Klienci WHERE ID_Klienta = p_id_klienta;
END;
$$;

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

CREATE OR REPLACE PROCEDURE sp_dodaj_pracownika(
    p_imie VARCHAR, p_nazwisko VARCHAR, p_stanowisko VARCHAR,
    p_login VARCHAR, p_haslo VARCHAR
) LANGUAGE plpgsql AS $$
BEGIN
    INSERT INTO Pracownicy (Imie, Nazwisko, Stanowisko, Login, Haslo)
    VALUES (p_imie, p_nazwisko, p_stanowisko, p_login, p_haslo);
END;
$$;

CREATE OR REPLACE PROCEDURE sp_usun_pracownika(p_id INT)
LANGUAGE plpgsql AS $$
BEGIN
    UPDATE Rezerwacje SET ID_Pracownika = NULL WHERE ID_Pracownika = p_id;
    DELETE FROM Pracownicy WHERE ID_Pracownika = p_id;
END;
$$;

CREATE OR REPLACE FUNCTION fn_pobierz_klientow()
RETURNS TABLE (ID_Klienta INT, Imie VARCHAR, Nazwisko VARCHAR, PESEL VARCHAR, Telefon VARCHAR) AS $$
BEGIN
    RETURN QUERY SELECT k.ID_Klienta, k.Imie, k.Nazwisko, k.PESEL, k.Telefon FROM Klienci k;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION fn_pobierz_klasy()
RETURNS TABLE (Nazwa_Klasy VARCHAR, Cena_Za_Dobe DECIMAL) AS $$
BEGIN
    RETURN QUERY SELECT k.Nazwa_Klasy, k.Cena_Za_Dobe FROM Klasy_Pojazdow k;
END;
$$;

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
        WHERE EXTRACT(YEAR FROM p.Data_Platnosci) = p_rok
        AND p.Status_Platnosci = 'Zrealizowana'
        GROUP BY 1, 2
    )
    SELECT
        w_m_txt::TEXT, w_gotowka, w_karta, w_przelew, w_razem,
        SUM(w_razem) OVER (ORDER BY w_m_num)::DECIMAL
    FROM Dane ORDER BY w_m_num;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION RankingKlientowVIP(top_n INT)
RETURNS TABLE (Pozycja BIGINT, Klient VARCHAR, Ile_Rezerwacji BIGINT, Wydano DECIMAL) AS $$
BEGIN
    RETURN QUERY
    WITH Rank AS (
        SELECT
            (k.Imie || ' ' || k.Nazwisko)::VARCHAR as w_klient,
            COUNT(r.ID_Rezerwacji) as w_ile,
            SUM(p.Kwota_Calkowita) as w_hajs,
            DENSE_RANK() OVER (ORDER BY SUM(p.Kwota_Calkowita) DESC) as w_poz
        FROM Klienci k
        JOIN Rezerwacje r ON k.ID_Klienta = r.ID_Klienta
        JOIN Platnosci p ON r.ID_Rezerwacji = p.ID_Rezerwacji
        WHERE p.Status_Platnosci = 'Zrealizowana'
        GROUP BY k.ID_Klienta
    )
    SELECT w_poz, w_klient, w_ile, w_hajs FROM Rank WHERE w_poz <= top_n;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION AnalizaPrzestojow(min_dni_przerwy INT)
RETURNS TABLE (Pojazd VARCHAR, Od DATE, Do DATE, Dni_Przestoju INT) AS $$
BEGIN
    RETURN QUERY
    WITH Luki AS (
        SELECT
            p.ID_Pojazdu,
            (p.Marka || ' ' || p.Model)::VARCHAR as w_auto,
            r.Data_Zwrotu as w_data_zwrotu,
            LEAD(r.Data_Odbioru) OVER (PARTITION BY p.ID_Pojazdu ORDER BY r.Data_Odbioru) as w_next_start
        FROM Pojazdy p
        JOIN Rezerwacje r ON p.ID_Pojazdu = r.ID_Pojazdu
        WHERE r.Status_Rezerwacji != 'Anulowana'
    )
    SELECT
        w_auto,
        w_data_zwrotu,
        w_next_start,
        (w_next_start - w_data_zwrotu)::INT
    FROM Luki
    WHERE (w_next_start - w_data_zwrotu) >= min_dni_przerwy;
END;
$$ LANGUAGE plpgsql;

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

CREATE OR REPLACE FUNCTION OblozenieMiesieczne(p_rok INT, p_miesiac INT)
RETURNS TABLE (Dzien DATE, Liczba_Aut INT) AS $$
BEGIN
    RETURN QUERY
    SELECT
        kalendarz::DATE,
        COUNT(r.ID_Rezerwacji)::INT
    FROM generate_series(
        MAKE_DATE(p_rok, p_miesiac, 1),
        (MAKE_DATE(p_rok, p_miesiac, 1) + INTERVAL '1 month' - INTERVAL '1 day'),
        '1 day'
    ) as kalendarz
    LEFT JOIN Rezerwacje r ON kalendarz BETWEEN r.Data_Odbioru AND r.Data_Zwrotu
    AND r.Status_Rezerwacji != 'Anulowana'
    GROUP BY kalendarz
    ORDER BY kalendarz;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION EfektywnoscPracownikow()
RETURNS TABLE (Pracownik VARCHAR, Obrót DECIMAL, Srednia_Firmy DECIMAL, Wynik_Proc DECIMAL) AS $$
BEGIN
    RETURN QUERY
    WITH Stats AS (
        SELECT
            (pr.Imie || ' ' || pr.Nazwisko)::VARCHAR as osoba,
            COALESCE(SUM(r.Cena_Calkowita), 0) as obrot
        FROM Pracownicy pr
        LEFT JOIN Rezerwacje r ON pr.ID_Pracownika = r.ID_Pracownika
        GROUP BY pr.ID_Pracownika
    )
    SELECT
        osoba,
        obrot,
        AVG(obrot) OVER ()::DECIMAL(10,2),
        (obrot / NULLIF(AVG(obrot) OVER (), 0) * 100)::DECIMAL(5,2)
    FROM Stats
    ORDER BY obrot DESC;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION StatusKlientow()
RETURNS TABLE (Klient VARCHAR, Ostatni_Wynajem DATE, Dni_Temu INT, Status TEXT) AS $$
BEGIN
    RETURN QUERY
    SELECT
        (k.Imie || ' ' || k.Nazwisko)::VARCHAR,
        MAX(r.Data_Zwrotu),
        (CURRENT_DATE - MAX(r.Data_Zwrotu))::INT,
        CASE
            WHEN MAX(r.Data_Zwrotu) IS NULL THEN 'Nowy / Brak historii'
            WHEN (CURRENT_DATE - MAX(r.Data_Zwrotu)) <= 30 THEN 'Aktywny'
            WHEN (CURRENT_DATE - MAX(r.Data_Zwrotu)) <= 180 THEN 'Uśpiony'
            ELSE 'Utracony'
        END
    FROM Klienci k
    LEFT JOIN Rezerwacje r ON k.ID_Klienta = r.ID_Klienta
    GROUP BY k.ID_Klienta
    ORDER BY 3;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION PrognozaSerwisowa(limit_km_serwisu INT DEFAULT 15000)
RETURNS TABLE (Pojazd VARCHAR, Przebieg INT, Km_Do_Serwisu INT, Status_Serwisu TEXT) AS $$
BEGIN
    RETURN QUERY
    SELECT
        (p.Marka || ' ' || p.Model)::VARCHAR,
        p.Przebieg,
        (limit_km_serwisu - (p.Przebieg - COALESCE(MAX(s.Przebieg_W_Chwili_Serwisu), 0)))::INT as pozostalo,
        CASE
            WHEN (p.Przebieg - COALESCE(MAX(s.Przebieg_W_Chwili_Serwisu), 0)) >= limit_km_serwisu THEN '❗ SERWIS NATYCHMIAST'
            WHEN (p.Przebieg - COALESCE(MAX(s.Przebieg_W_Chwili_Serwisu), 0)) >= (limit_km_serwisu * 0.9) THEN '⚠️ Blisko serwisu'
            ELSE '✅ OK'
        END
    FROM Pojazdy p
    LEFT JOIN Serwisy s ON p.ID_Pojazdu = s.ID_Pojazdu
    GROUP BY p.ID_Pojazdu;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION SzukajPojazdu(fraza TEXT)
RETURNS SETOF Pojazdy AS $$
BEGIN
    RETURN QUERY
    SELECT * FROM Pojazdy p
    WHERE p.Marka ILIKE '%' || fraza || '%'
       OR p.Model ILIKE '%' || fraza || '%'
       OR p.Numer_Rejestracyjny ILIKE '%' || fraza || '%';
END;
$$ LANGUAGE plpgsql;
---------------------------------------------------------------------------------
-- 2. DANE TESTOWE
---------------------------------------------------------------------------------
TRUNCATE Rezerwacje_Uslugi, Platnosci, Serwisy, Rezerwacje, Pojazdy, Klienci, Pracownicy, Klasy_Pojazdow, Uslugi_Dodatkowe RESTART IDENTITY CASCADE;

---------------------------------------------------------------------------------
-- 1. BAZA (KLASY, USŁUGI, PRACOWNICY Z LOGINAMI)
---------------------------------------------------------------------------------
INSERT INTO Klasy_Pojazdow (Nazwa_Klasy, Cena_Za_Dobe) VALUES
('Ekonomiczna', 90.00), ('Kompakt', 140.00), ('Standard', 190.00),
('SUV', 250.00), ('Premium', 450.00), ('Sport', 600.00);

INSERT INTO Uslugi_Dodatkowe (Nazwa_Uslugi, Cena) VALUES
('Pełne Ubezpieczenie', 50.00), ('GPS', 20.00), ('Fotelik Dziecięcy', 15.00), ('Dodatkowy Kierowca', 30.00);

-- LOGINY: admin/admin, ewa/ewa, piotr/piotr
INSERT INTO Pracownicy (Imie, Nazwisko, Stanowisko, Login, Haslo) VALUES
('Adam', 'Nowacki', 'Menadżer', 'admin', 'admin'),
('Ewa', 'Kowalska', 'Sprzedawca', 'ewa', 'ewa'),
('Piotr', 'Wiśniewski', 'Serwisant', 'piotr', 'piotr');

---------------------------------------------------------------------------------
-- 2. FLOTA
---------------------------------------------------------------------------------
INSERT INTO Pojazdy (ID_Klasy, Marka, Model, Rok_Produkcji, Numer_Rejestracyjny, Przebieg, Stan_Techniczny, Status_Dostepnosci) VALUES
(1, 'Toyota', 'Yaris', 2022, 'WA 10001', 45000, 'Bardzo Dobry', 'Dostępny'),
(1, 'Skoda', 'Fabia', 2021, 'WA 10002', 62000, 'Dobry', 'Dostępny'),
(1, 'Kia', 'Rio', 2023, 'KR 20001', 15000, 'Idealny', 'Dostępny'),
(1, 'Fiat', '500', 2020, 'KR 20002', 80000, 'Dobry', 'Dostępny'),
(2, 'VW', 'Golf', 2022, 'PO 30001', 35000, 'Bardzo Dobry', 'Wypożyczony'),
(2, 'Ford', 'Focus', 2021, 'GD 40001', 58000, 'Dobry', 'Dostępny'),
(2, 'Opel', 'Astra', 2023, 'GD 40002', 12000, 'Idealny', 'Dostępny'),
(3, 'Toyota', 'Camry', 2023, 'DW 50001', 22000, 'Idealny', 'Dostępny'),
(3, 'Mazda', '6', 2020, 'LU 60001', 95000, 'Wymaga przeglądu', 'W serwisie'),
(3, 'VW', 'Passat', 2021, 'LU 60002', 60000, 'Bardzo Dobry', 'Dostępny'),
(4, 'Kia', 'Sportage', 2023, 'SK 70001', 28000, 'Bardzo Dobry', 'Dostępny'),
(4, 'Hyundai', 'Tucson', 2022, 'WA 80001', 42000, 'Bardzo Dobry', 'Wypożyczony'),
(4, 'Volvo', 'XC60', 2021, 'WA 80002', 75000, 'Dobry', 'Dostępny'),
(5, 'BMW', 'X5', 2023, 'KR VIP01', 12000, 'Idealny', 'Dostępny'),
(5, 'Mercedes', 'E-Class', 2022, 'WA VIP02', 30000, 'Idealny', 'Dostępny'),
(5, 'Audi', 'Q7', 2021, 'GD VIP03', 85000, 'Dobry', 'Dostępny'),
(5, 'Lexus', 'RX', 2023, 'PO VIP04', 5000, 'Idealny', 'Dostępny'),
(6, 'Porsche', '911', 2022, 'P0 RSCHE', 15000, 'Idealny', 'W serwisie'),
(6, 'Ford', 'Mustang', 2021, 'W0 MUSCLE', 45000, 'Bardzo Dobry', 'Dostępny'),
(6, 'Dodge', 'Challenger', 2020, 'D0 HEMI', 55000, 'Dobry', 'Dostępny');

---------------------------------------------------------------------------------
-- 3. KLIENCI
---------------------------------------------------------------------------------
INSERT INTO Klienci (Imie, Nazwisko, PESEL, Numer_Prawa_Jazdy, Telefon, Email, Adres) VALUES
('Jan', 'Kowalski', '80010112345', 'PJ001', '500100100', 'jan@mail.com', 'Warszawa'),
('Anna', 'Nowak', '90020254321', 'PJ002', '600200200', 'anna@mail.com', 'Kraków'),
('Piotr', 'Zieliński', '85030311111', 'PJ003', '700300300', 'piotr@mail.com', 'Gdańsk'),
('Kasia', 'Wiśniewska', '95040422222', 'PJ004', '501501501', 'kasia@mail.com', 'Wrocław'),
('Marek', 'Wójcik', '78050533333', 'PJ005', '602602602', 'marek@mail.com', 'Poznań'),
('Tomasz', 'Kamiński', '88060644444', 'PJ006', '703703703', 'tomek@mail.com', 'Łódź'),
('Magda', 'Lewandowska', '92070755555', 'PJ007', '504504504', 'magda@mail.com', 'Szczecin'),
('Paweł', 'Dąbrowski', '81080866666', 'PJ008', '605605605', 'pawel@mail.com', 'Bydgoszcz'),
('Monika', 'Szymańska', '99090977777', 'PJ009', '706706706', 'monika@mail.com', 'Lublin'),
('Krzysztof', 'Woźniak', '83101088888', 'PJ010', '507507507', 'krzys@mail.com', 'Katowice'),
('Barbara', 'Kozłowska', '75111199999', 'PJ011', '608608608', 'basia@mail.com', 'Gdynia'),
('Michał', 'Jankowski', '89121200000', 'PJ012', '709709709', 'michal@mail.com', 'Częstochowa'),
('Agnieszka', 'Mazur', '94010112121', 'PJ013', '510510510', 'aga@mail.com', 'Radom'),
('Jakub', 'Krawczyk', '96020223232', 'PJ014', '611611611', 'kuba@mail.com', 'Sosnowiec'),
('Ewelina', 'Kaczmarek', '91030334343', 'PJ015', '712712712', 'ewelina@mail.com', 'Toruń'),
('Wojciech', 'Piotrowski', '82040445454', 'PJ016', '513513513', 'wojtek@mail.com', 'Kielce'),
('Alicja', 'Grabowska', '98050556565', 'PJ017', '614614614', 'ala@mail.com', 'Rzeszów'),
('Mateusz', 'Pawłowski', '93060667676', 'PJ018', '715715715', 'mati@mail.com', 'Gliwice'),
('Natalia', 'Michalska', '97070778787', 'PJ019', '516516516', 'nati@mail.com', 'Zabrze'),
('Grzegorz', 'Nowicki', '84080889898', 'PJ020', '617617617', 'grzes@mail.com', 'Olsztyn');

---------------------------------------------------------------------------------
-- 4. HISTORIA REZERWACJI
---------------------------------------------------------------------------------

-- === ROK 2023 ===
INSERT INTO Rezerwacje (ID_Klienta, ID_Pojazdu, ID_Pracownika, Data_Rezerwacji, Data_Odbioru, Data_Zwrotu, Miejsce_Odbioru, Cena_Calkowita, Status_Rezerwacji) VALUES
(1, 1, 1, '2023-01-05', '2023-01-10', '2023-01-15', 'Warszawa', 450.00, 'Zakończona'),
(2, 5, 2, '2023-02-12', '2023-02-15', '2023-02-20', 'Kraków', 700.00, 'Zakończona'),
(3, 10, 3, '2023-03-01', '2023-03-05', '2023-03-10', 'Gdańsk', 950.00, 'Zakończona'),
(4, 2, 2, '2023-03-20', '2023-03-25', '2023-03-28', 'Wrocław', 270.00, 'Zakończona'),
(5, 14, 1, '2023-06-01', '2023-06-15', '2023-06-25', 'Poznań', 4500.00, 'Zakończona'),
(6, 18, 2, '2023-07-05', '2023-07-10', '2023-07-12', 'Sopot', 1200.00, 'Zakończona'),
(7, 19, 1, '2023-07-15', '2023-07-20', '2023-07-27', 'Gdynia', 4200.00, 'Zakończona'),
(8, 11, 2, '2023-08-01', '2023-08-05', '2023-08-15', 'Zakopane', 2500.00, 'Zakończona'),
(9, 3, 3, '2023-10-10', '2023-10-15', '2023-10-20', 'Lublin', 450.00, 'Zakończona'),
(10, 6, 2, '2023-11-05', '2023-11-10', '2023-11-12', 'Katowice', 280.00, 'Zakończona'),
(11, 15, 1, '2023-12-20', '2023-12-23', '2023-12-27', 'Kraków', 2250.00, 'Zakończona');

INSERT INTO Platnosci (ID_Rezerwacji, Kwota_Calkowita, Data_Platnosci, Forma_Platnosci, Status_Platnosci) VALUES
(1, 450.00, '2023-01-15', 'Karta', 'Zrealizowana'),
(2, 700.00, '2023-02-20', 'Gotówka', 'Zrealizowana'),
(3, 950.00, '2023-03-10', 'Przelew', 'Zrealizowana'),
(4, 270.00, '2023-03-28', 'Karta', 'Zrealizowana'),
(5, 4500.00, '2023-06-25', 'Przelew', 'Zrealizowana'),
(6, 1200.00, '2023-07-12', 'Karta', 'Zrealizowana'),
(7, 4200.00, '2023-07-27', 'Gotówka', 'Zrealizowana'),
(8, 2500.00, '2023-08-15', 'Karta', 'Zrealizowana'),
(9, 450.00, '2023-10-20', 'Gotówka', 'Zrealizowana'),
(10, 280.00, '2023-11-12', 'Karta', 'Zrealizowana'),
(11, 2250.00, '2023-12-27', 'Przelew', 'Zrealizowana');

-- === ROK 2024 ===
INSERT INTO Rezerwacje (ID_Klienta, ID_Pojazdu, ID_Pracownika, Data_Rezerwacji, Data_Odbioru, Data_Zwrotu, Miejsce_Odbioru, Cena_Calkowita, Status_Rezerwacji) VALUES
(12, 14, 2, '2024-01-05', '2024-01-10', '2024-01-20', 'Zakopane', 4500.00, 'Zakończona'),
(13, 12, 1, '2024-02-14', '2024-02-14', '2024-02-16', 'Warszawa', 500.00, 'Zakończona'),
(14, 18, 3, '2024-03-10', '2024-03-15', '2024-03-16', 'Tor Poznań', 1200.00, 'Zakończona'),
(15, 8, 2, '2024-04-01', '2024-04-05', '2024-04-10', 'Wrocław', 950.00, 'Zakończona'),
(1, 19, 1, '2024-05-01', '2024-05-01', '2024-05-05', 'Sopot', 2400.00, 'Zakończona'),
(2, 17, 2, '2024-06-15', '2024-06-20', '2024-06-30', 'Gdańsk', 4500.00, 'Zakończona'),
(3, 11, 3, '2024-07-01', '2024-07-05', '2024-07-15', 'Mazury', 2800.00, 'Zakończona'),
(4, 5, 2, '2024-08-10', '2024-08-15', '2024-08-25', 'Kraków', 1400.00, 'Zakończona'),
(5, 4, 1, '2024-09-01', '2024-09-05', '2024-09-10', 'Warszawa', 450.00, 'Zakończona'),
(6, 16, 2, '2024-10-05', '2024-10-10', '2024-10-15', 'Łódź', 2250.00, 'Zakończona'),
(7, 9, 3, '2024-11-20', '2024-11-25', '2024-11-28', 'Rzeszów', 570.00, 'Zakończona'),
(8, 15, 2, '2024-12-24', '2024-12-24', '2024-12-31', 'Zakopane', 3150.00, 'Zakończona');

INSERT INTO Platnosci (ID_Rezerwacji, Kwota_Calkowita, Data_Platnosci, Forma_Platnosci, Status_Platnosci) VALUES
(12, 4500.00, '2024-01-20', 'Karta', 'Zrealizowana'),
(13, 500.00, '2024-02-16', 'Gotówka', 'Zrealizowana'),
(14, 1200.00, '2024-03-16', 'Karta', 'Zrealizowana'),
(15, 950.00, '2024-04-10', 'Przelew', 'Zrealizowana'),
(16, 2400.00, '2024-05-05', 'Karta', 'Zrealizowana'),
(17, 4500.00, '2024-06-30', 'Przelew', 'Zrealizowana'),
(18, 2800.00, '2024-07-15', 'Gotówka', 'Zrealizowana'),
(19, 1400.00, '2024-08-25', 'Karta', 'Zrealizowana'),
(20, 450.00, '2024-09-10', 'Gotówka', 'Zrealizowana'),
(21, 2250.00, '2024-10-15', 'Przelew', 'Zrealizowana'),
(22, 570.00, '2024-11-28', 'Karta', 'Zrealizowana'),
(23, 3150.00, '2024-12-31', 'Przelew', 'Zrealizowana');

-- === ROK 2025 ===
INSERT INTO Rezerwacje (ID_Klienta, ID_Pojazdu, ID_Pracownika, Data_Rezerwacji, Data_Odbioru, Data_Zwrotu, Miejsce_Odbioru, Cena_Calkowita, Status_Rezerwacji) VALUES
(9, 1, 1, '2025-01-10', '2025-01-15', '2025-01-20', 'Warszawa', 450.00, 'Zakończona'),
(10, 7, 2, '2025-02-15', '2025-02-20', '2025-02-25', 'Gdańsk', 700.00, 'Zakończona'),
(11, 13, 3, '2025-03-05', '2025-03-10', '2025-03-15', 'Wrocław', 1250.00, 'Zakończona'),
(12, 19, 2, '2025-04-20', '2025-04-25', '2025-04-28', 'Poznań', 1800.00, 'Zakończona'),
(13, 20, 1, '2025-05-15', '2025-05-20', '2025-05-22', 'Kraków', 1200.00, 'Zakończona'),
(14, 14, 2, '2025-06-10', '2025-06-15', '2025-06-30', 'Sopot', 6750.00, 'Zakończona'),
(15, 6, 3, '2025-07-01', '2025-07-05', '2025-07-20', 'Gdynia', 2100.00, 'Zakończona'),
(16, 12, 2, '2025-08-10', '2025-08-15', '2025-08-25', 'Lublin', 2500.00, 'Zakończona'),
(17, 3, 1, '2025-09-05', '2025-09-10', '2025-09-12', 'Warszawa', 180.00, 'Zakończona'),
(18, 10, 2, '2025-10-15', '2025-10-20', '2025-10-25', 'Katowice', 950.00, 'Zakończona'),
(19, 17, 3, '2025-11-20', '2025-11-25', '2025-11-30', 'Rzeszów', 2250.00, 'Zakończona'),
(20, 8, 2, '2025-12-10', '2025-12-15', '2025-12-20', 'Kraków', 950.00, 'Zakończona');

INSERT INTO Platnosci (ID_Rezerwacji, Kwota_Calkowita, Data_Platnosci, Forma_Platnosci, Status_Platnosci) VALUES
(24, 450.00, '2025-01-20', 'Gotówka', 'Zrealizowana'),
(25, 700.00, '2025-02-25', 'Karta', 'Zrealizowana'),
(26, 1250.00, '2025-03-15', 'Przelew', 'Zrealizowana'),
(27, 1800.00, '2025-04-28', 'Karta', 'Zrealizowana'),
(28, 1200.00, '2025-05-22', 'Gotówka', 'Zrealizowana'),
(29, 6750.00, '2025-06-30', 'Przelew', 'Zrealizowana'),
(30, 2100.00, '2025-07-20', 'Karta', 'Zrealizowana'),
(31, 2500.00, '2025-08-25', 'Gotówka', 'Zrealizowana'),
(32, 180.00, '2025-09-12', 'Karta', 'Zrealizowana'),
(33, 950.00, '2025-10-25', 'Przelew', 'Zrealizowana'),
(34, 2250.00, '2025-11-30', 'Karta', 'Zrealizowana'),
(35, 950.00, '2025-12-20', 'Gotówka', 'Zrealizowana');

-- === STYCZEŃ 2026 ===
INSERT INTO Rezerwacje (ID_Klienta, ID_Pojazdu, ID_Pracownika, Data_Rezerwacji, Data_Odbioru, Data_Zwrotu, Miejsce_Odbioru, Cena_Calkowita, Status_Rezerwacji) VALUES
(1, 2, 1, '2026-01-02', '2026-01-03', '2026-01-05', 'Warszawa', 270.00, 'Zakończona'),
(2, 5, 2, '2026-01-04', '2026-01-06', '2026-01-10', 'Kraków', 560.00, 'Potwierdzona'),
(3, 12, 3, '2026-01-05', '2026-01-15', '2026-01-20', 'Gdańsk', 1250.00, 'Potwierdzona'),
(4, 14, 2, '2026-01-01', '2026-01-02', '2026-01-04', 'Wrocław', 900.00, 'Zakończona'),
(5, 1, 1, '2026-01-08', '2026-01-10', '2026-01-12', 'Poznań', 180.00, 'Potwierdzona');

INSERT INTO Platnosci (ID_Rezerwacji, Kwota_Calkowita, Data_Platnosci, Forma_Platnosci, Status_Platnosci) VALUES
(36, 270.00, '2026-01-05', 'Karta', 'Zrealizowana'),
(39, 900.00, '2026-01-04', 'Gotówka', 'Zrealizowana');

---------------------------------------------------------------------------------
-- 5. SERWISY
---------------------------------------------------------------------------------
INSERT INTO Serwisy (ID_Pojazdu, Data_Serwisu, Opis, Koszt, Przebieg_W_Chwili_Serwisu) VALUES
(1, '2025-10-01', 'Przegląd olejowy', 400.00, 40000),
(9, '2025-12-01', 'Awaria skrzyni', 4500.00, 95000),
(18, '2025-11-15', 'Wymiana klocków', 2000.00, 14000),
(2, '2024-05-05', 'Duży przegląd', 1200.00, 50000);
---------------------------------------------------------------------------------
-- 2. DANE TESTOWE (WERSJA "FULL BUSY" - SYMULACJA RUCHU)
---------------------------------------------------------------------------------
TRUNCATE Rezerwacje_Uslugi, Platnosci, Serwisy, Rezerwacje, Pojazdy, Klienci, Pracownicy, Klasy_Pojazdow, Uslugi_Dodatkowe RESTART IDENTITY CASCADE;

---------------------------------------------------------------------------------
-- 1. BAZA (SŁOWNIKI)
---------------------------------------------------------------------------------
INSERT INTO Klasy_Pojazdow (Nazwa_Klasy, Cena_Za_Dobe) VALUES
('Ekonomiczna', 90.00), ('Kompakt', 140.00), ('Standard', 190.00),
('SUV', 250.00), ('Premium', 450.00), ('Sport', 600.00), ('Elektryk', 350.00), ('Van', 300.00);

INSERT INTO Uslugi_Dodatkowe (Nazwa_Uslugi, Cena) VALUES
('Pełne Ubezpieczenie', 50.00), ('GPS', 20.00), ('Fotelik', 15.00), ('Kierowca', 30.00);

INSERT INTO Pracownicy (Imie, Nazwisko, Stanowisko, Login, Haslo) VALUES
('Adam', 'Nowacki', 'Menadżer', 'admin', 'admin'),
('Ewa', 'Kowalska', 'Sprzedawca', 'ewa', 'ewa'),
('Piotr', 'Wiśniewski', 'Serwisant', 'piotr', 'piotr'),
('Karolina', 'Szybka', 'Sprzedawca', 'karola', 'karola123');

---------------------------------------------------------------------------------
-- 2. FLOTA (30 AUT - WIELE 'WYPOŻYCZONYCH')
---------------------------------------------------------------------------------
INSERT INTO Pojazdy (ID_Klasy, Marka, Model, Rok_Produkcji, Numer_Rejestracyjny, Przebieg, Stan_Techniczny, Status_Dostepnosci, Wymaga_Serwisu, Opis_Usterki) VALUES
-- EKONOMICZNE (Ciągły ruch)
(1, 'Toyota', 'Yaris', 2022, 'WA 10001', 58000, 'Idealny', 'Dostępny', FALSE, NULL),
(1, 'Skoda', 'Fabia', 2021, 'WA 10002', 76000, 'Stuki w zawieszeniu', 'Dostępny', TRUE, 'Stuki w zawieszeniu (LP)'),
(1, 'Kia', 'Rio', 2023, 'KR 20001', 31000, 'Idealny', 'Wypożyczony', FALSE, NULL), -- Wypożyczony
(1, 'Fiat', '500', 2020, 'KR 20002', 92000, 'Dostateczny', 'Dostępny', TRUE, 'Opony do wymiany'),
(1, 'Dacia', 'Duster', 2020, 'WA TANIE', 145000, 'Średni', 'Wypożyczony', FALSE, NULL), -- Wypożyczony
(1, 'Renault', 'Clio', 2018, 'WA WORK', 160000, 'Wymaga naprawy', 'W serwisie', TRUE, 'Wyciek oleju'),

-- KOMPAKT (Standardowe)
(2, 'VW', 'Golf', 2022, 'PO 30001', 48000, 'Idealny', 'Wypożyczony', FALSE, NULL), -- Wypożyczony
(2, 'Ford', 'Focus', 2021, 'GD 40001', 71000, 'Dobry', 'Dostępny', TRUE, 'Check Engine'),
(2, 'Opel', 'Astra', 2023, 'GD 40002', 26000, 'Idealny', 'Dostępny', FALSE, NULL),
(2, 'Peugeot', '308', 2023, 'FR 1234', 19000, 'Idealny', 'Wypożyczony', FALSE, NULL), -- Wypożyczony

-- STANDARD / ŚREDNIA
(3, 'Toyota', 'Camry', 2023, 'DW 50001', 35000, 'Idealny', 'Dostępny', FALSE, NULL),
(3, 'Mazda', '6', 2020, 'LU 60001', 110000, 'Awaria', 'W serwisie', TRUE, 'Skrzynia biegów'),
(3, 'VW', 'Passat', 2021, 'LU 60002', 78000, 'Idealny', 'Wypożyczony', FALSE, NULL), -- Wypożyczony
(3, 'Honda', 'Civic', 2021, 'JP VTEC', 59000, 'Idealny', 'Dostępny', FALSE, NULL),

-- SUV
(4, 'Kia', 'Sportage', 2023, 'SK 70001', 41000, 'Idealny', 'Dostępny', FALSE, NULL),
(4, 'Hyundai', 'Tucson', 2022, 'WA 80001', 56000, 'Idealny', 'Wypożyczony', FALSE, NULL), -- Wypożyczony
(4, 'Volvo', 'XC60', 2021, 'WA 80002', 89000, 'Dobry', 'Dostępny', FALSE, NULL),

-- PREMIUM & VIP
(5, 'BMW', 'X5', 2023, 'KR VIP01', 25000, 'Idealny', 'Dostępny', FALSE, NULL),
(5, 'Mercedes', 'E-Class', 2022, 'WA VIP02', 42000, 'Idealny', 'Wypożyczony', FALSE, NULL), -- Wypożyczony
(5, 'Audi', 'Q7', 2021, 'GD VIP03', 98000, 'Dobry', 'Dostępny', FALSE, NULL),
(5, 'Lexus', 'RX', 2023, 'PO VIP04', 18000, 'Idealny', 'Dostępny', FALSE, NULL),
(5, 'Range Rover', 'Sport', 2022, 'RR KING', 42000, 'Idealny', 'Wypożyczony', FALSE, NULL), -- Wypożyczony

-- SPORT
(6, 'Porsche', '911', 2022, 'P0 RSCHE', 26000, 'Awaria', 'W serwisie', TRUE, 'Rozrząd do sprawdzenia'),
(6, 'Ford', 'Mustang', 2021, 'W0 MUSCLE', 58000, 'Idealny', 'Dostępny', FALSE, NULL),
(6, 'Dodge', 'Challenger', 2020, 'D0 HEMI', 68000, 'Dobry', 'Dostępny', FALSE, NULL),
(6, 'Chevrolet', 'Camaro', 2019, 'US POWER', 72000, 'Dobry', 'Wypożyczony', FALSE, NULL), -- Wypożyczony

-- INNE (ELEKTRYK, VAN)
(7, 'Tesla', 'Model 3', 2023, 'EL 0001', 22000, 'Idealny', 'Dostępny', FALSE, NULL),
(7, 'Tesla', 'Model Y', 2022, 'EL 0002', 38000, 'Idealny', 'Wypożyczony', FALSE, NULL), -- Wypożyczony
(8, 'Mercedes', 'V-Class', 2021, 'WA BUS01', 95000, 'Dobry', 'Dostępny', FALSE, NULL),
(8, 'VW', 'Multivan', 2023, 'WA BUS02', 28000, 'Idealny', 'Wypożyczony', FALSE, NULL); -- Wypożyczony

---------------------------------------------------------------------------------
-- 3. KLIENCI (50 OSÓB - NORMALNE DANE)
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
('Grzegorz', 'Nowicki', '84080889898', 'PJ020', '617617617', 'grzes@mail.com', 'Olsztyn'),
('Karolina', 'Jóźwiak', '01053155551', 'PJ021', '600100201', 'karolina.j@poczta.pl', 'Kalisz'),
('Dariusz', 'Wróbel', '84120766661', 'PJ022', '600300401', 'darek.w@firma.pl', 'Słupsk'),
('Patryk', 'Stępień', '97021177771', 'PJ023', '600500601', 'patryk.s@student.pl', 'Wrocław'),
('Kamila', 'Zając', '53071088881', 'PJ024', '600700801', 'kamila.z@biuro.pl', 'Warszawa'),
('Adrian', 'Baran', '69062399991', 'PJ025', '600900001', 'adrian.b@tech.pl', 'Białystok'),
('Dominika', 'Sikora', '62061311221', 'PJ026', '601111221', 'dominika.s@szkola.pl', 'Gniezno'),
('Bartosz', 'Pawlak', '78090433441', 'PJ027', '601333441', 'bartek.p@budowa.pl', 'Łódź'),
('Izabela', 'Głowacka', '93052355661', 'PJ028', '601555661', 'iza.g@poczta.pl', 'Konin'),
('Rafał', 'Zakrzewski', '97090277881', 'PJ029', '601777881', 'rafal.z@auto.pl', 'Warszawa'),
('Sylwia', 'Czarnecka', '00071499001', 'PJ030', '601999001', 'sylwia.c@studia.pl', 'Kraków'),
('Łukasz', 'Mazurek', '96021311231', 'PJ031', '602111231', 'lukasz.m@it.pl', 'Poznań'),
('Natalia', 'Sobczak', '96083122341', 'PJ032', '602222341', 'natalia.s@design.pl', 'Sopot'),
('Mariusz', 'Krajewski', '82072133451', 'PJ033', '602333451', 'mariusz.k@transport.pl', 'Warszawa'),
('Justyna', 'Włodarczyk', '63081244561', 'PJ034', '602444561', 'justyna.w@urzad.pl', 'Kraków'),
('Artur', 'Marciniak', '61030255671', 'PJ035', '602555671', 'artur.m@sklep.pl', 'Warszawa'),
('Kinga', 'Mróz', '77071466781', 'PJ036', '602666781', 'kinga.m@dom.pl', 'Gdańsk'),
('Damian', 'Lis', '63080277891', 'PJ037', '602777891', 'damian.l@bank.pl', 'Szczecin'),
('Oliwia', 'Wysocka', '02101888901', 'PJ038', '602888901', 'oliwia.w@szkola.pl', 'Gdynia'),
('Kamil', 'Kubiak', '98122399011', 'PJ039', '602999011', 'kamil.k@poczta.fm', 'Bydgoszcz'),
('Martyna', 'Wilk', '95021100121', 'PJ040', '603000121', 'martyna.w@korpo.pl', 'Warszawa'),
('Sebastian', 'Kołodziej', '70010154321', 'PJ041', '500500501', 'seba.k@warsztat.pl', 'Radom'),
('Halina', 'Błaszczyk', '72020265431', 'PJ042', '500600601', 'halina.b@emeryt.pl', 'Lublin'),
('Przemysław', 'Kaźmierczak', '99030376541', 'PJ043', '500700701', 'przemek.k@logistyka.pl', 'Pruszków'),
('Wiktoria', 'Rutkowska', '01040487651', 'PJ044', '500800801', 'wiki.r@student.pl', 'Płock'),
('Jacek', 'Szulc', '71062811121', 'PJ045', '100200301', 'jacek.s@biznes.pl', 'Rzeszów'),
('Beata', 'Gajewska', '84051433341', 'PJ046', '100400501', 'beata.g@szpital.pl', 'Opole'),
('Andrzej', 'Klimek', '55102855561', 'PJ047', '100600701', 'andrzej.k@bud.pl', 'Zielona Góra'),
('Joanna', 'Nawrocka', '55022477781', 'PJ048', '100800901', 'asia.n@poczta.onet.pl', 'Gorzów'),
('Mirosław', 'Bednarek', '64011299901', 'PJ049', '100111221', 'mirek.b@rolnik.pl', 'Suwałki'),
('Renata', 'Jasińska', '60110112311', 'PJ050', '100333441', 'renata.j@ksiegowa.pl', 'Zakopane');

---------------------------------------------------------------------------------
-- 4. HISTORIA REZERWACJI (2024-2026)
---------------------------------------------------------------------------------
INSERT INTO Rezerwacje (ID_Klienta, ID_Pojazdu, ID_Pracownika, Data_Rezerwacji, Data_Odbioru, Data_Zwrotu, Miejsce_Odbioru, Cena_Calkowita, Status_Rezerwacji) VALUES
-- === ROK 2024 (HISTORIA) ===
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
(8, 15, 2, '2024-12-24', '2024-12-24', '2024-12-31', 'Zakopane', 3150.00, 'Zakończona'),
(33, 27, 4, '2024-01-10', '2024-01-15', '2024-01-18', 'Warszawa', 1350.00, 'Zakończona'),
(40, 26, 4, '2024-02-14', '2024-02-14', '2024-02-16', 'Kraków', 1200.00, 'Zakończona'),
(21, 21, 1, '2024-03-01', '2024-03-01', '2024-03-10', 'Warszawa', 3500.00, 'Zakończona'),
(46, 22, 2, '2024-04-15', '2024-04-20', '2024-04-25', 'Gdańsk', 1750.00, 'Zakończona'),
(27, 24, 3, '2024-05-01', '2024-05-01', '2024-05-05', 'Łódź', 1200.00, 'Zakończona'),
(23, 29, 1, '2024-06-01', '2024-06-10', '2024-06-20', 'Wrocław', 1900.00, 'Zakończona'),
(29, 21, 4, '2024-07-01', '2024-07-01', '2024-07-30', 'Warszawa', 10500.00, 'Zakończona'),
(37, 26, 2, '2024-08-01', '2024-08-01', '2024-08-03', 'Sopot', 1200.00, 'Zakończona'),
(50, 21, 1, '2024-09-10', '2024-09-12', '2024-09-15', 'Warszawa', 1050.00, 'Zakończona'),
(22, 27, 2, '2024-10-01', '2024-10-05', '2024-10-10', 'Kraków', 2250.00, 'Zakończona'),
(26, 25, 4, '2024-11-15', '2024-11-20', '2024-11-22', 'Warszawa', 600.00, 'Zakończona'),
(48, 21, 1, '2024-12-01', '2024-12-05', '2024-12-10', 'Warszawa', 1750.00, 'Zakończona'),
(10, 1, 1, '2024-02-10', '2024-02-11', '2024-02-15', 'Warszawa', 450.00, 'Zakończona'),
(11, 2, 2, '2024-03-05', '2024-03-06', '2024-03-10', 'Kraków', 600.00, 'Zakończona'),
(12, 3, 3, '2024-04-15', '2024-04-16', '2024-04-20', 'Gdańsk', 450.00, 'Zakończona'),
(13, 7, 1, '2024-05-20', '2024-05-21', '2024-05-25', 'Poznań', 700.00, 'Zakończona'),
(14, 13, 2, '2024-06-10', '2024-06-11', '2024-06-15', 'Wrocław', 1250.00, 'Zakończona'),
(15, 20, 3, '2024-07-05', '2024-07-06', '2024-07-10', 'Szczecin', 3000.00, 'Zakończona'),
(16, 30, 1, '2024-08-15', '2024-08-16', '2024-08-20', 'Warszawa', 450.00, 'Zakończona'),

-- === ROK 2025 (BARDZO GĘSTO) ===
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
(20, 8, 2, '2025-12-10', '2025-12-15', '2025-12-20', 'Kraków', 950.00, 'Zakończona'),
(21, 27, 4, '2025-01-05', '2025-01-10', '2025-01-15', 'Warszawa', 2250.00, 'Zakończona'),
(22, 26, 4, '2025-02-14', '2025-02-14', '2025-02-17', 'Kraków', 1800.00, 'Zakończona'),
(30, 22, 1, '2025-03-20', '2025-03-25', '2025-03-28', 'Warszawa', 1050.00, 'Zakończona'),
(34, 25, 2, '2025-04-10', '2025-04-15', '2025-04-25', 'Kraków', 3000.00, 'Zakończona'),
(38, 29, 3, '2025-05-01', '2025-05-01', '2025-05-10', 'Gdańsk', 1900.00, 'Zakończona'),
(42, 23, 1, '2025-06-15', '2025-06-15', '2025-06-30', 'Radom', 1350.00, 'Zakończona'),
(49, 21, 4, '2025-07-01', '2025-07-05', '2025-07-15', 'Warszawa', 3500.00, 'Zakończona'),
(25, 24, 2, '2025-08-01', '2025-08-01', '2025-08-10', 'Białystok', 2000.00, 'Zakończona'),
(31, 26, 1, '2025-09-10', '2025-09-15', '2025-09-20', 'Kraków', 3000.00, 'Zakończona'),
(43, 28, 3, '2025-10-05', '2025-10-05', '2025-10-08', 'Pruszków', 420.00, 'Zakończona'),
(45, 27, 4, '2025-11-15', '2025-11-20', '2025-11-25', 'Warszawa', 2250.00, 'Zakończona'),
(36, 21, 2, '2025-12-24', '2025-12-24', '2025-12-26', 'Zakopane', 700.00, 'Zakończona'),
(30, 2, 1, '2025-04-01', '2025-04-05', '2025-04-10', 'Warszawa', 600.00, 'Zakończona'),
(31, 4, 2, '2025-05-15', '2025-05-20', '2025-05-25', 'Kraków', 450.00, 'Zakończona'),
(32, 5, 3, '2025-06-10', '2025-06-15', '2025-06-20', 'Gdańsk', 700.00, 'Zakończona'),
(33, 9, 1, '2025-07-20', '2025-07-25', '2025-07-30', 'Poznań', 1200.00, 'Zakończona'),
(34, 11, 2, '2025-08-05', '2025-08-10', '2025-08-15', 'Wrocław', 2500.00, 'Zakończona'),
(35, 15, 3, '2025-09-15', '2025-09-20', '2025-09-25', 'Szczecin', 2250.00, 'Zakończona'),
(36, 16, 1, '2025-10-10', '2025-10-15', '2025-10-20', 'Warszawa', 2250.00, 'Zakończona'),
(37, 18, 2, '2025-11-05', '2025-11-10', '2025-11-15', 'Kraków', 3000.00, 'Zakończona'),
(38, 30, 3, '2025-12-01', '2025-12-05', '2025-12-10', 'Gdańsk', 450.00, 'Zakończona'),

-- === STYCZEŃ/LUTY 2026 - AKTUALNY STAN "W TRAKCIE" I PRZYSZŁE ===
(1, 2, 1, '2026-01-02', '2026-01-03', '2026-01-05', 'Warszawa', 270.00, 'Zakończona'),
(2, 6, 2, '2026-01-04', '2026-01-06', '2026-01-10', 'Kraków', 560.00, 'Zakończona'),
(3, 1, 3, '2026-01-05', '2026-01-15', '2026-01-22', 'Gdańsk', 1250.00, 'Zakończona'),
(4, 14, 2, '2026-01-01', '2026-01-02', '2026-01-04', 'Wrocław', 900.00, 'Zakończona'),
-- W TRAKCIE (Zgodne z tabelą Pojazdy)
(10, 3, 1, '2026-01-20', '2026-01-21', '2026-01-30', 'Warszawa', 900.00, 'W trakcie'),  -- Rio (Wypożyczony)
(11, 5, 2, '2026-01-22', '2026-01-23', '2026-02-05', 'Kraków', 1800.00, 'W trakcie'),  -- Duster (Wypożyczony)
(12, 7, 3, '2026-01-24', '2026-01-24', '2026-01-31', 'Gdańsk', 1000.00, 'W trakcie'),  -- Golf (Wypożyczony)
(13, 10, 1, '2026-01-20', '2026-01-22', '2026-01-29', 'Wrocław', 1400.00, 'W trakcie'), -- Peugeot (Wypożyczony)
(14, 13, 2, '2026-01-15', '2026-01-16', '2026-02-01', 'Poznań', 3000.00, 'W trakcie'), -- Passat (Wypożyczony)
(15, 16, 3, '2026-01-24', '2026-01-25', '2026-01-30', 'Szczecin', 1250.00, 'W trakcie'), -- Tucson (Wypożyczony)
(16, 19, 1, '2026-01-23', '2026-01-24', '2026-01-28', 'Warszawa', 2000.00, 'W trakcie'), -- E-Class (Wypożyczony)
(17, 21, 2, '2026-01-20', '2026-01-21', '2026-01-30', 'Kraków', 4500.00, 'W trakcie'), -- Range Rover (Wypożyczony)
(18, 26, 3, '2026-01-22', '2026-01-23', '2026-01-27', 'Gdańsk', 3000.00, 'W trakcie'), -- Camaro (Wypożyczony)
(19, 28, 1, '2026-01-21', '2026-01-22', '2026-02-05', 'Lublin', 3500.00, 'W trakcie'), -- Tesla Y (Wypożyczony)
(20, 30, 2, '2026-01-24', '2026-01-24', '2026-02-10', 'Katowice', 5000.00, 'W trakcie'), -- Multivan (Wypożyczony)

-- PRZYSZŁE
(21, 2, 4, '2026-02-01', '2026-02-05', '2026-02-10', 'Warszawa', 700.00, 'Potwierdzona'),
(22, 4, 3, '2026-02-02', '2026-02-10', '2026-02-15', 'Kraków', 450.00, 'Potwierdzona'),
(23, 8, 2, '2026-02-05', '2026-02-12', '2026-02-18', 'Gdańsk', 1200.00, 'Potwierdzona');

---------------------------------------------------------------------------------
-- 5. PŁATNOŚCI (DLA WSZYSTKICH REZERWACJI ZAKOŃCZONYCH)
---------------------------------------------------------------------------------
INSERT INTO Platnosci (ID_Rezerwacji, Kwota_Calkowita, Data_Platnosci, Forma_Platnosci, Status_Platnosci)
SELECT
    ID_Rezerwacji,
    Cena_Calkowita,
    Data_Zwrotu,
    CASE WHEN ID_Rezerwacji % 3 = 0 THEN 'Gotówka' WHEN ID_Rezerwacji % 3 = 1 THEN 'Karta' ELSE 'Przelew' END,
    'Zrealizowana'
FROM Rezerwacje
WHERE Status_Rezerwacji = 'Zakończona';

---------------------------------------------------------------------------------
-- 6. SERWISY (HISTORIA NAPRAW)
---------------------------------------------------------------------------------
INSERT INTO Serwisy (ID_Pojazdu, Data_Serwisu, Opis, Koszt, Przebieg_W_Chwili_Serwisu) VALUES
(1, '2025-10-01', 'Przegląd olejowy', 400.00, 40000),
(9, '2025-12-01', 'Awaria skrzyni', 4500.00, 95000),
(18, '2025-11-15', 'Wymiana klocków', 2000.00, 14000),
(2, '2024-05-05', 'Duży przegląd', 1200.00, 50000),
(30, '2025-12-10', 'Usuwanie wycieku oleju', 600.00, 148000),
(23, '2025-11-01', 'Nabijanie klimatyzacji', 200.00, 110000),
(25, '2025-06-01', 'Wymiana opon', 300.00, 20000),
(10, '2025-09-10', 'Naprawa blacharska', 2500.00, 60000);
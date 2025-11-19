# 🚗 System Zarządzania Wypożyczalnią Samochodów  
**Dokumentacja projektu + model bazy danych**

---

## 📌 Opis projektu
Celem projektu jest stworzenie kompletnego systemu bazodanowego do obsługi wypożyczalni samochodów.  
System umożliwia zarządzanie flotą, klientami, rezerwacjami, usługami dodatkowymi, płatnościami oraz historią serwisową pojazdów.

Projekt zawiera:
- kompletny model ERD  
- skrypt SQL  
- model DBML do dbdiagram.io  
- pełny opis tabel  
- historię wersji (changelog)

---
<img width="1484" height="988" alt="image" src="https://github.com/user-attachments/assets/61dce6f1-6572-4911-9c72-cf72d5adfaa2" />

# 🗂️ Struktura bazy danych

System składa się z następujących tabel:

- **Klienci** — dane klientów  
- **Pracownicy** — obsługa wypożyczalni  
- **Klasy_Pojazdow** — kategorie pojazdów  
- **Pojazdy** — flota samochodów  
- **Rezerwacje** — wynajmy klientów  
- **Uslugi_Dodatkowe** — dodatkowe opcje wyposażenia  
- **Rezerwacje_Uslugi** — usługi powiązane z rezerwacjami  
- **Platnosci** — płatności i faktury  
- **Serwisy** — historia serwisowa pojazdów  

---

# 🧬 Opisy tabel

## **Klienci**  
**Opis:** Przechowuje dane klientów korzystających z usług wypożyczalni.  
**Pola:**  
ID_Klienta, Imie, Nazwisko, PESEL, Numer_Prawa_Jazdy, Telefon, Email, Adres  

---

## **Pracownicy**  
**Opis:** Rejestr pracowników obsługujących rezerwacje.  
**Pola:**  
ID_Pracownika, Imie, Nazwisko, Stanowisko  

---

## **Klasy_Pojazdow**  
**Opis:** Słownik klas pojazdów z ceną wynajmu za dobę.  
**Pola:**  
ID_Klasy, Nazwa_Klasy, Cena_Za_Dobe  

---

## **Pojazdy**  
**Opis:** Flota samochodów dostępnych w wypożyczalni.  
**Pola:**  
ID_Pojazdu, ID_Klasy, Marka, Model, Rok_Produkcji, Numer_Rejestracyjny, Przebieg, Stan_Techniczny, Status_Dostepnosci  

---

## **Rezerwacje**  
**Opis:** Rejestr wszystkich rezerwacji pojazdów.  
**Pola:**  
ID_Rezerwacji, ID_Klienta, ID_Pojazdu, ID_Pracownika, Data_Rezerwacji, Data_Odbioru, Data_Zwrotu, Miejsce_Odbioru, Cena_Calkowita, Status_Rezerwacji  

---

## **Uslugi_Dodatkowe**  
**Opis:** Usługi dodatkowe oferowane klientom (np. nawigacja, fotelik).  
**Pola:**  
ID_Uslugi, Nazwa_Uslugi, Cena  

---

## **Rezerwacje_Uslugi**  
**Opis:** Powiązanie rezerwacji z usługami dodatkowymi (N:M).  
**Pola:**  
ID_Rezerwacji_Uslugi, ID_Rezerwacji, ID_Uslugi  

---

## **Platnosci**  
**Opis:** Szczegóły płatności i faktur za rezerwacje.  
**Pola:**  
ID_Platnosci, ID_Rezerwacji, Kwota_Calkowita, Data_Platnosci, Forma_Platnosci, Status_Platnosci, Numer_Faktury  

---

## **Serwisy**  
**Opis:** Historia przeglądów i napraw pojazdów.  
**Pola:**  
ID_Serwisu, ID_Pojazdu, Data_Serwisu, Opis, Koszt, Przebieg_W_Chwili_Serwisu  

---

# 🧩 ERD (DBML) – wersja 1.2

Pełny model DBML:  
//////////////////////////////////////////////////////////
// Tabela: Klienci
//////////////////////////////////////////////////////////

Table Klienci {
  ID_Klienta int [pk, increment, not null]
  Imie varchar(50) [not null]
  Nazwisko varchar(50) [not null]
  PESEL char(11) [unique, not null]
  Numer_Prawa_Jazdy varchar(20) [not null]
  Telefon varchar(20) [not null]
  Email varchar(100) [not null]
  Adres varchar(150) [not null]

  Note: 'Lista klientów korzystających z usług wypożyczalni.'
}

//////////////////////////////////////////////////////////
// Tabela: Pracownicy
//////////////////////////////////////////////////////////

Table Pracownicy {
  ID_Pracownika int [pk, increment, not null]
  Imie varchar(50) [not null]
  Nazwisko varchar(50) [not null]
  Stanowisko varchar(50) [not null]

  Note: 'Dane pracowników obsługujących wypożyczalnię.'
}

//////////////////////////////////////////////////////////
// Tabela: Klasy_Pojazdow
//////////////////////////////////////////////////////////

Table Klasy_Pojazdow {
  ID_Klasy int [pk, increment, not null]
  Nazwa_Klasy varchar(20) [not null]
  Cena_Za_Dobe decimal(10,2) [not null]

  Note: 'Słownik klas pojazdów wraz z ceną za dobę.'
}

//////////////////////////////////////////////////////////
// Tabela: Pojazdy
//////////////////////////////////////////////////////////

Table Pojazdy {
  ID_Pojazdu int [pk, increment, not null]
  ID_Klasy int [ref: > Klasy_Pojazdow.ID_Klasy, not null]
  Marka varchar(50) [not null]
  Model varchar(50) [not null]
  Rok_Produkcji year [not null]
  Numer_Rejestracyjny varchar(15) [unique, not null]
  Przebieg int [not null]
  Stan_Techniczny varchar(100) [not null]
  Status_Dostepnosci enum('Dostępny', 'Wypożyczony', 'W serwisie') [not null]

  indexes {
    (Numer_Rejestracyjny)
  }

  Note: 'Flota pojazdów dostępnych w wypożyczalni.'
}

//////////////////////////////////////////////////////////
// Tabela: Rezerwacje
//////////////////////////////////////////////////////////

Table Rezerwacje {
  ID_Rezerwacji int [pk, increment, not null]
  ID_Klienta int [ref: > Klienci.ID_Klienta, not null]
  ID_Pojazdu int [ref: > Pojazdy.ID_Pojazdu, not null]
  ID_Pracownika int [ref: > Pracownicy.ID_Pracownika, not null]
  Data_Rezerwacji date [not null]
  Data_Odbioru date [not null]
  Data_Zwrotu date [not null]
  Miejsce_Odbioru varchar(100) [not null]
  Cena_Calkowita decimal(10,2) [not null]
  Status_Rezerwacji enum('Potwierdzona', 'Zakończona', 'Anulowana') [not null]

  Note: 'Rezerwacje zawarte przez klientów, obsłużone przez pracownika.'
}

//////////////////////////////////////////////////////////
// CHECK constraints (komentarze, bo DBML nie obsługuje CHECK)
//////////////////////////////////////////////////////////

// CHECK: Data_Rezerwacji <= Data_Odbioru
// CHECK: Data_Odbioru <= Data_Zwrotu
// CHECK: Cena_Calkowita > 0

//////////////////////////////////////////////////////////
// Tabela: Uslugi_Dodatkowe
//////////////////////////////////////////////////////////

Table Uslugi_Dodatkowe {
  ID_Uslugi int [pk, increment, not null]
  Nazwa_Uslugi varchar(100) [not null]
  Cena decimal(10,2) [not null]

  Note: 'Dodatkowe usługi oferowane klientom (np. GPS, fotelik).'
}

//////////////////////////////////////////////////////////
// Tabela: Rezerwacje_Uslugi (N:M)
//////////////////////////////////////////////////////////

Table Rezerwacje_Uslugi {
  ID_Rezerwacji_Uslugi int [pk, increment, not null]
  ID_Rezerwacji int [ref: > Rezerwacje.ID_Rezerwacji, not null]
  ID_Uslugi int [ref: > Uslugi_Dodatkowe.ID_Uslugi, not null]

  indexes {
    (ID_Rezerwacji, ID_Uslugi) [unique]
  }

  Note: 'Powiązanie rezerwacji z zakupionymi usługami dodatkowymi.'
}

//////////////////////////////////////////////////////////
// Tabela: Platnosci
//////////////////////////////////////////////////////////

Table Platnosci {
  ID_Platnosci int [pk, increment, not null]
  ID_Rezerwacji int [ref: > Rezerwacje.ID_Rezerwacji, not null]
  Kwota_Calkowita decimal(10,2) [not null]
  Data_Platnosci date [not null]
  Forma_Platnosci enum('Gotówka', 'Karta', 'Przelew') [not null]
  Status_Platnosci enum('Oczekująca', 'Zrealizowana', 'Anulowana') [not null]
  Numer_Faktury varchar(30) [not null]

  Note: 'Płatności i faktury powiązane z rezerwacjami.'
}

//////////////////////////////////////////////////////////
// Tabela: Serwisy (Historia pojazdów)
//////////////////////////////////////////////////////////

Table Serwisy {
  ID_Serwisu int [pk, increment, not null]
  ID_Pojazdu int [ref: > Pojazdy.ID_Pojazdu, not null]
  Data_Serwisu date [not null]
  Opis varchar(200) [not null]
  Koszt decimal(10,2) [not null]
  Przebieg_W_Chwili_Serwisu int [not null]

  Note: 'Historia serwisowa i naprawy wykonane na pojazdach.'
}

---

# 🧾 Changelog

## **v1.2 — aktualna wersja (rozszerzona)**
✔ Dodano tabelę `Pracownicy`  
✔ Dodano tabelę `Serwisy`  
✔ Dodano indeksy i unique constraints  
✔ Wprowadzono NOT NULL do wszystkich kluczowych pól  
✔ Dodano CHECK constraints (komentarze)  
✔ Rozszerzono opisy tabel  
✔ Ulepszono relacje i strukturę ERD  
✔ Dodano pola usprawniające logikę biznesową

---

## **v1.1 — poprzednia wersja**
✔ Zawierała podstawowe tabele:  
`Klienci, Klasy_Pojazdow, Pojazdy, Rezerwacje, Uslugi_Dodatkowe, Rezerwacje_Uslugi, Platnosci`  
✔ Logiczna i poprawna, ale uproszczona  
✔ Bez tabeli Pracownicy i Serwisy  
✔ Bez szczegółowych constraintów i indeksów  

---

# 🚀 Autor  
Projekt przygotowany w ramach nauki projektowania relacyjnych baz danych i modelowania ERD.


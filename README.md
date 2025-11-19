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
*(tutaj możesz wkleić wersję DBML, którą wygenerowałem wcześniej)*

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


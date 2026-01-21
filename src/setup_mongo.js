/* * SKRYPT INICJALIZACYJNY BAZY NOSQL (MongoDB)
 * Projekt: System Wypożyczalni Samochodów
 * * Zastosowanie:
 * Baza NoSQL służy do przechowywania danych o dużej objętości i zmiennej strukturze,
 * których nie opłaca się trzymać w relacyjnym PostgreSQL.
 */

// 1. Wybór bazy danych
use wypozyczalnia_nosql;

// 2. Kolekcja: LOGI SYSTEMOWE (Audit Log)

db.createCollection("logs");

db.logs.insertMany([
    {
        "timestamp": new Date("2023-10-01T08:00:00Z"),
        "level": "INFO",
        "user": "admin",
        "action": "LOGIN_SUCCESS",
        "ip_address": "192.168.1.10",
        "details": {
            "browser": "Chrome",
            "os": "Windows 10"
        }
    },
    {
        "timestamp": new Date("2023-10-01T08:15:00Z"),
        "level": "WARNING",
        "user": "jan.kowalski",
        "action": "DELETE_ATTEMPT",
        "resource": "Pojazd_ID_4",
        "message": "Próba usunięcia pojazdu z aktywną rezerwacją"
    },
    {
        "timestamp": new Date("2023-10-01T09:30:00Z"),
        "level": "ERROR",
        "module": "PaymentService",
        "error_code": 503,
        "message": "Brak połączenia z bramką płatności",
        "stack_trace": "TimeoutError at /api/pay..."
    }
]);

// 3. Kolekcja: TELEMETRIA POJAZDÓW (IoT / GPS)
// Dane z czujników w autach.

db.createCollection("telemetry");

db.telemetry.insertMany([
    {
        "vehicle_id": 10,
        "timestamp": new Date("2023-10-05T12:00:00Z"),
        "gps": {
            "lat": 52.2297,
            "lon": 21.0122
        },
        "status": {
            "speed_kmh": 50,
            "fuel_level_percent": 85,
            "engine_temp": 90,
            "doors_locked": true
        }
    },
    {
        "vehicle_id": 10,
        "timestamp": new Date("2023-10-05T12:05:00Z"),
        "gps": {
            "lat": 52.2300,
            "lon": 21.0130
        },
        "status": {
            "speed_kmh": 65,
            "fuel_level_percent": 84,
            "engine_temp": 92,
            "doors_locked": true
        }
    },
    {
        "vehicle_id": 5,
        "timestamp": new Date("2023-10-05T14:20:00Z"),
        "alert": "CRITICAL",
        "message": "Wykryto uderzenie / wypadek",
        "g_force": 4.5,
        "airbags_deployed": false
    }
]);

// 4. Kolekcja: ARCHIWUM UMÓW (Dokumenty prawne)

db.createCollection("contracts_archive");

db.contracts_archive.insertOne({
    "reservation_id": 1024,
    "client_pesel": "90010112345",
    "signed_date": new Date("2023-09-01"),
    "contract_version": "v2.1",
    "terms_accepted": ["RODO", "Regulamin", "Ubezpieczenie"],
    "digital_signature_hash": "a1b2c3d4e5f6..."
});

print("Zainicjalizowano strukturę bazy NoSQL: wypozyczalnia_nosql");
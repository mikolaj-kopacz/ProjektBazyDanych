import psycopg2
import pandas as pd
import streamlit as st


def get_db_config():
    try:
        return st.secrets["postgres"]
    except Exception:
        return {
            "dbname": "wypozyczalnia_db",
            "user": "postgres",
            "password": "admin",
            "host": "localhost",
            "port": "5432",
        }


def get_connection():
    config = get_db_config()
    if isinstance(config, str):
        return psycopg2.connect(config)
    return psycopg2.connect(**config)


def run_query(query, params=None):
    conn = get_connection()
    try:
        df = pd.read_sql(query, conn, params=params)
        return df
    finally:
        conn.close()


def run_command(command, params=None):
    conn = get_connection()
    cur = conn.cursor()
    try:
        cur.execute(command, params)
        conn.commit()
        return True, "Sukces"
    except Exception as e:
        conn.rollback()
        return False, str(e)
    finally:
        cur.close()
        conn.close()


def check_login(username, password):
    sql = "SELECT ID_Pracownika, Imie, Nazwisko, Stanowisko FROM Pracownicy WHERE Login=%s AND Haslo=%s"
    df = run_query(sql, (username, password))
    if not df.empty:
        return df.iloc[0].to_dict()
    return None

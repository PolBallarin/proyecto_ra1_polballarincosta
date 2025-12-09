-- ============================================
-- DDL para Datawarehouse - Market Data
-- Generado desde ETL con Pandas
-- ============================================

-- TABLAS DIMENSIONALES

CREATE TABLE IF NOT EXISTS dim_asset (
    asset_id INTEGER PRIMARY KEY,
    symbol TEXT,
    name TEXT,
    market_type TEXT
);

CREATE TABLE IF NOT EXISTS dim_sector (
    sector_id INTEGER PRIMARY KEY,
    sector_name TEXT
);

CREATE TABLE IF NOT EXISTS dim_exchange (
    exchange_id INTEGER PRIMARY KEY,
    exchange_name TEXT
);

CREATE TABLE IF NOT EXISTS dim_currency (
    currency_id INTEGER PRIMARY KEY,
    currency_name TEXT
);

CREATE TABLE IF NOT EXISTS dim_country (
    country_id INTEGER PRIMARY KEY,
    country_name TEXT
);

CREATE TABLE IF NOT EXISTS dim_date (
    date_id INTEGER PRIMARY KEY,
    date TEXT,
    year TEXT,
    month TEXT,
    day TEXT,
    weekday TEXT
);

-- TABLA DE HECHOS

CREATE TABLE IF NOT EXISTS fact_market_data (
    fact_id INTEGER PRIMARY KEY,
    asset_id INTEGER,
    date_id INTEGER,
    sector_id INTEGER,
    exchange_id INTEGER,
    currency_id INTEGER,
    country_id INTEGER,
    open REAL,
    close REAL,
    high REAL,
    low REAL,
    volume REAL,
    market_cap REAL,
    daily_change REAL,
    daily_change_pct REAL,
    last_updated TEXT,
    FOREIGN KEY (asset_id) REFERENCES dim_asset(asset_id),
    FOREIGN KEY (date_id) REFERENCES dim_date(date_id),
    FOREIGN KEY (sector_id) REFERENCES dim_sector(sector_id),
    FOREIGN KEY (exchange_id) REFERENCES dim_exchange(exchange_id),
    FOREIGN KEY (currency_id) REFERENCES dim_currency(currency_id),
    FOREIGN KEY (country_id) REFERENCES dim_country(country_id)
);

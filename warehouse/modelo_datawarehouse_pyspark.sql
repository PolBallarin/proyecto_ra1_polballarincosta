-- DDL Datawarehouse Market Data (PySpark)


CREATE TABLE dim_asset (
    symbol TEXT,
    name TEXT,
    market_type TEXT,
    asset_id INTEGER PRIMARY KEY
);

CREATE TABLE dim_sector (
    sector_name TEXT,
    sector_id INTEGER PRIMARY KEY
);

CREATE TABLE dim_exchange (
    exchange_name TEXT,
    exchange_id INTEGER PRIMARY KEY
);

CREATE TABLE dim_currency (
    currency_name TEXT,
    currency_id INTEGER PRIMARY KEY
);

CREATE TABLE dim_country (
    country_name TEXT,
    country_id INTEGER PRIMARY KEY
);

CREATE TABLE dim_date (
    date DATE,
    date_id INTEGER PRIMARY KEY,
    year INTEGER,
    month INTEGER,
    day INTEGER,
    weekday INTEGER
);

CREATE TABLE fact_market_data (
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
    FOREIGN KEY (asset_id) REFERENCES dim_asset(asset_id),
    FOREIGN KEY (date_id) REFERENCES dim_date(date_id),
    FOREIGN KEY (sector_id) REFERENCES dim_sector(sector_id),
    FOREIGN KEY (exchange_id) REFERENCES dim_exchange(exchange_id),
    FOREIGN KEY (currency_id) REFERENCES dim_currency(currency_id),
    FOREIGN KEY (country_id) REFERENCES dim_country(country_id)
);
# Proyecto RA1 - Big Data: ETL y Datawarehouse para Datos de Mercado

**Autor:** Pol Ballarin Costa  
**Fecha:** Diciembre 2025

---

## 📋 Descripción del Proyecto

Este proyecto implementa un proceso completo de ETL (Extract, Transform, Load) para limpiar y transformar datos de mercado financiero (acciones y criptomonedas), creando un Datawarehouse estructurado con modelo dimensional (Star Schema). El proyecto utiliza tanto **Pandas** como **PySpark** para procesar los datos, demostrando diferentes enfoques de procesamiento de datos.

### Dataset

El dataset contiene **10,000 registros** de datos de mercado con información de:
- **Acciones (stocks):** MSFT, GOOGL, TSLA, AMZN, AAPL
- **Criptomonedas (crypto):** BTC, ETH, SOL, ADA, BNB

### Objetivos

- Realizar exploración y limpieza exhaustiva de datos de mercado financiero
- Implementar procesos ETL con Pandas y PySpark
- Crear un Datawarehouse con modelo dimensional (1 tabla de hechos + 6 tablas de dimensiones)
- Generar DDLs para la estructura del Datawarehouse
- Contenedorizar el entorno con Docker
- Documentar todo el proceso y resultados

---

## 🗂️ Estructura de Carpetas

```
proyecto_market_data/
├── data/                              # Datos del proyecto
│   ├── market_data.csv                # Dataset original
│   ├── market_data_clean.csv          # Dataset limpio (Pandas)
│   └── market_data_clean_spark.csv    # Dataset limpio (PySpark)
│
├── notebooks/                         # Notebooks Jupyter
│   ├── 01_pandas.ipynb               # ETL con Pandas
│   └── 02_pyspark.ipynb              # ETL con PySpark
│
├── warehouse/                         # Datawarehouse
│   ├── warehouse_pandas.db           # Base de datos SQLite (Pandas)
│   ├── warehouse_pyspark.db          # Base de datos SQLite (PySpark)
│   ├── modelo_datawarehouse_pandas.sql    # DDL del modelo (Pandas)
│   └── modelo_datawarehouse_pyspark.sql   # DDL del modelo (PySpark)
│
├── docs/                             # Documentación
│   └── README.md                     # Este archivo
│   └── diagrama.drawio               # Diagrama del modelo dimensional
│
├── Dockerfile                        # Imagen Docker
├── docker-compose.yml                # Orquestación de contenedores
└── requirements.txt                  # Dependencias Python
```

---

## 🛠️ Herramientas Utilizadas

### Lenguajes y Frameworks
- **Python 3.11**: Lenguaje de programación principal
- **Pandas**: Biblioteca para manipulación y análisis de datos
- **PySpark 4.0.1**: Framework para procesamiento distribuido de datos
- **SQLite**: Base de datos relacional para el Datawarehouse
- **SQLAlchemy**: ORM para conexión con SQLite

### Herramientas de Desarrollo
- **Jupyter Notebook/Lab**: Entorno de desarrollo interactivo
- **Docker**: Contenedorización del entorno de desarrollo
- **Docker Compose**: Orquestación de contenedores

### Librerías Python
- `pandas`: Manipulación de DataFrames
- `pyspark`: Procesamiento distribuido
- `numpy`: Operaciones numéricas
- `sqlalchemy`: Conexión a bases de datos
- `re`: Expresiones regulares para limpieza de datos

---

## 📊 Problemas Detectados en el Dataset

Durante la fase de exploración se identificaron los siguientes problemas de calidad:

| Columna | Problema | Solución Aplicada |
|---------|----------|-------------------|
| `date` | 3 formatos diferentes: MM-DD-YYYY, YYYY-MM-DD, DD/MM/YYYY | Detección con regex + parsing condicional |
| `open` | 513 valores con texto ("4892.63 USD") | Extracción de números con regex |
| `currency` | 4 variantes: usd, USD, $, USDT | Normalización a "USD" |
| `sector` | 16 valores inconsistentes (tech/Tech/TECHNOLOGY, blockchain/Crypto) | Mapeo a 6 categorías |
| `exchange` | 138 "Unknown" + 361 nulos | Reemplazo por "exchange_empty" |
| `symbol` | 213 nulos | Rellenado usando mapeo name→symbol |

---

## 📊 Explicación de Cada Fase

### Fase 1: Exploración y Limpieza con Pandas (`01_pandas.ipynb`)

**Objetivo:** Explorar y limpiar el dataset usando Pandas.

**Proceso:**
1. **Carga de datos**: Lectura del CSV original
2. **Análisis exploratorio**: 
   - Detección de 574 valores nulos totales
   - Identificación de 0 duplicados
   - Análisis de valores únicos por columna
3. **Limpieza de datos**:
   - Extracción de números de columna `open`
   - Normalización de `currency` a "USD"
   - Mapeo de 16 sectores a 6 categorías
   - Parsing de 3 formatos de fecha
   - Rellenado de `symbol` usando `name`
4. **Columnas derivadas**:
   - `daily_change`: cambio absoluto (close - open)
   - `daily_change_pct`: cambio porcentual

**Resultado:** Dataset limpio con 10,000 filas y 17 columnas

---

### Fase 2: Procesamiento con PySpark (`02_pyspark.ipynb`)

**Objetivo:** Replicar el proceso ETL usando PySpark.

**Diferencias con Pandas:**
- **Evaluación lazy**: Las transformaciones no se ejecutan hasta una acción
- **Inmutabilidad**: Cada transformación crea un nuevo DataFrame
- **Funciones nativas**: Uso de `when()`, `regexp_extract()`, `make_date()` en lugar de UDFs
- **Parseo de fechas**: Uso de `make_date()` con `split()` para evitar errores de formato

**Resultado:** Dataset limpio guardado en `market_data_clean_spark.csv`

---

### Fase 3: Modelo de Data Warehouse

**Modelo Star Schema con 1 tabla de hechos y 6 dimensiones:**

#### Tabla de Hechos: `fact_market_data`
- **Métricas:** open, close, high, low, volume, market_cap, daily_change, daily_change_pct
- **Foreign Keys:** asset_id, date_id, sector_id, exchange_id, currency_id, country_id

#### Tablas Dimensionales

| Dimensión | Descripción | Registros |
|-----------|-------------|-----------|
| `dim_asset` | Activos (symbol, name, market_type) | 10 |
| `dim_sector` | Sectores (Finance, Technology, Retail, Crypto, AI, Automotive) | 6 |
| `dim_exchange` | Exchanges (NASDAQ, NYSE, BINANCE, COINBASE, exchange_empty) | 5 |
| `dim_currency` | Monedas (USD) | 1 |
| `dim_country` | Países (US, Global) | 2 |
| `dim_date` | Fechas con componentes (year, month, day, weekday) | ~600 |

---

### Fase 4: Docker

**Archivos de configuración:**

**Dockerfile:**
- Base: `python:3.11-slim`
- Instalación de Java JDK (requerido para PySpark)
- Instalación de dependencias desde `requirements.txt`
- Puerto 8888 para Jupyter

**docker-compose.yml:**
- Volúmenes montados: data, notebooks, docs, warehouse
- Variable de entorno para JupyterLab
- Reinicio automático del contenedor

---

## 🚀 Instrucciones de Ejecución

### Opción 1: Con Docker (Recomendado)

1. **Navegar al directorio del proyecto:**
   ```bash
   cd proyecto_market_data
   ```

2. **Construir y ejecutar el contenedor:**
   ```bash
   docker-compose up --build
   ```

3. **Acceder a Jupyter:**
   - Abrir navegador en: `http://localhost:8888`

4. **Ejecutar los notebooks en orden:**
   - `01_pandas.ipynb`
   - `02_pyspark.ipynb`

### Opción 2: Sin Docker

1. **Instalar dependencias:**
   ```bash
   pip install jupyter pandas pyspark sqlalchemy numpy
   ```

2. **Instalar Java JDK** (requerido para PySpark)

3. **Iniciar Jupyter:**
   ```bash
   jupyter notebook
   ```

---

## 🔍 Consultas SQL de Ejemplo

### Precio promedio por activo
```sql
SELECT 
    a.symbol,
    a.name,
    AVG(f.close) as precio_promedio,
    COUNT(*) as total_registros
FROM fact_market_data f
JOIN dim_asset a ON f.asset_id = a.asset_id
GROUP BY a.symbol, a.name
ORDER BY precio_promedio DESC;
```

### Comparar rendimiento entre tipos de mercados
```sql
SELECT 
    a.market_type,
    AVG(f.daily_change_pct) as cambio_promedio,
    AVG(f.volume) as volumen_promedio,
    COUNT(*) as registros
FROM fact_market_data f
JOIN dim_asset a ON f.asset_id = a.asset_id
GROUP BY a.market_type;
```

### Precio máximo y mínimo histórico por activo
```sql
SELECT 
    a.symbol,
    MIN(f.low) as minimo_historico,
    MAX(f.high) as maximo_historico,
    AVG(f.close) as precio_medio
FROM fact_market_data f
JOIN dim_asset a ON f.asset_id = a.asset_id
GROUP BY a.symbol
ORDER BY maximo_historico DESC;
```

### Top 5 días con mayor cambio porcentual
```sql
SELECT 
    d.date,
    a.symbol,
    f.daily_change_pct,
    f.open,
    f.close
FROM fact_market_data f
JOIN dim_date d ON f.date_id = d.date_id
JOIN dim_asset a ON f.asset_id = a.asset_id
ORDER BY ABS(f.daily_change_pct) DESC
LIMIT 5;
```

### Análisis mensual por tipo de mercado
```sql
SELECT 
    d.year,
    d.month,
    a.market_type,
    AVG(f.close) as precio_promedio,
    AVG(f.volume) as volumen_promedio
FROM fact_market_data f
JOIN dim_date d ON f.date_id = d.date_id
JOIN dim_asset a ON f.asset_id = a.asset_id
GROUP BY d.year, d.month, a.market_type
ORDER BY d.year, d.month;
```

---

## 🔄 Comparación Pandas vs PySpark

| Aspecto | Pandas | PySpark |
|---------|--------|---------|
| **Procesamiento** | En memoria | Distribuido |
| **Evaluación** | Inmediata | Lazy (diferida) |
| **Mutabilidad** | Mutable | Inmutable |
| **Escalabilidad** | Limitada por RAM | Alta (clusters) |
| **Sintaxis fechas** | `pd.to_datetime()` | `make_date()` + `split()` |
| **Guardado CSV** | `to_csv()` directo | Requiere `toPandas()` en Windows |

---

## 🎓 Conclusiones

1. **Calidad de datos**: La limpieza de datos es crucial. Se detectaron múltiples problemas que requerían soluciones específicas.

2. **Pandas vs PySpark**: 
   - Pandas es más intuitivo para datasets pequeños
   - PySpark es necesario para escalabilidad pero requiere más configuración en Windows

3. **Modelo dimensional**: El Star Schema facilita consultas analíticas eficientes con JOINs simples.

4. **Docker**: La contenedorización garantiza reproducibilidad del entorno.

---

## 📚 Referencias

- [Documentación de Pandas](https://pandas.pydata.org/docs/)
- [Documentación de PySpark](https://spark.apache.org/docs/latest/api/python/)
- [SQLite Documentation](https://www.sqlite.org/docs.html)
- [Docker Documentation](https://docs.docker.com/)

---

## 👤 Autor

**Pol Ballarin Costa**  
Proyecto RA1 - Big Data  
Diciembre 2025
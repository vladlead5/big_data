# BigDataSparkLab

Лабораторная №2: ETL-пайплайн на PySpark — из CSV через PostgreSQL в ClickHouse.

## Ход работы

Всю инфраструктуру поднял через Docker Compose — PostgreSQL, ClickHouse и Jupyter крутятся в одной сети: `docker-compose.yml`.

Данные — 10 CSV-файлов, загрузил их в PostgreSQL через COPY в цикле: `sql/init.sql`.

Дальше PySpark: прочитал данные из PostgreSQL, разложил по схеме «звезда» (5 таблиц с измерениями и `fact_sales`), и записал 6 аналитических витрин в ClickHouse — всё в `notebooks/etl_pipeline.ipynb`.

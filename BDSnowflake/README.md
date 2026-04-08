# BigDataSnowflake

Лабораторная №1: ETL-пайплайн из CSV в схему снежинка (PostgreSQL).

## Ход работы

Мне было интересно как быстрее всего увидеть основные сущности, поэтому поработал с данными в jupyter'е — `notebooks/eda.ipynb`.

Затем записал всё в dbdiagram.io, результат: `dbml/schema.dbml`.

Оттуда же DDL: `sql/0002_ddl.sql`.

Импортировал 10 CSV в staging через COPY в цикле и сделал view для удобного доступа к сырым данным: `sql/0001_pull_files.sql`.

DML: `sql/0003_dml.sql`.

Валидация работы: `notebooks/validation.ipynb`.


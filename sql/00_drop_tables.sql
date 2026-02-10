-- Файл: sql/00_drop_tables.sql
-- Удаление всех таблиц в правильном порядке (из-за внешних ключей)

DROP VIEW IF EXISTS ProductionOverview;
DROP TABLE IF EXISTS ProductionLog;
DROP TABLE IF EXISTS Product_Materials;
DROP TABLE IF EXISTS Materials;
DROP TABLE IF EXISTS Employees;
DROP TABLE IF EXISTS Machines;
DROP TABLE IF EXISTS Operations;
DROP TABLE IF EXISTS Products;
DROP TABLE IF EXISTS Projects;

-- Если нужно удалить базу данных полностью
-- DROP DATABASE IF EXISTS cnbp_production_db;

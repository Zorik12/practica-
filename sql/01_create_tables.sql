-- Файл: sql/01_create_tables.sql
-- Создание базы данных для учета производственных процессов
-- Автор: [Ваше ФИО]
-- Дата: [Текущая дата]

-- Создание базы данных (если нужно)
CREATE DATABASE IF NOT EXISTS cnbp_production_db;
USE cnbp_production_db;

-- 1. Таблица "Проекты"
CREATE TABLE Projects (
    project_id INT PRIMARY KEY AUTO_INCREMENT,
    project_name VARCHAR(255) NOT NULL,
    client_name VARCHAR(255),
    start_date DATE,
    deadline DATE,
    status VARCHAR(50) DEFAULT 'В планировании',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

-- 2. Таблица "Изделия"
CREATE TABLE Products (
    product_id INT PRIMARY KEY AUTO_INCREMENT,
    product_name VARCHAR(255) NOT NULL,
    drawing_number VARCHAR(100),
    specification TEXT,
    project_id INT NOT NULL,
    FOREIGN KEY (project_id) REFERENCES Projects(project_id) ON DELETE CASCADE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 3. Таблица "Технологические операции"
CREATE TABLE Operations (
    operation_id INT PRIMARY KEY AUTO_INCREMENT,
    operation_name VARCHAR(255) NOT NULL,
    operation_code VARCHAR(50),
    standard_time DECIMAL(5,2) COMMENT 'Время в часах',
    required_qualification VARCHAR(100),
    description TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 4. Таблица "Оборудование"
CREATE TABLE Machines (
    machine_id INT PRIMARY KEY AUTO_INCREMENT,
    machine_name VARCHAR(255) NOT NULL,
    inventory_number VARCHAR(100) UNIQUE,
    manufacture_year INT,
    machine_type VARCHAR(100),
    status VARCHAR(50) DEFAULT 'Исправен',
    last_maintenance DATE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 5. Таблица "Сотрудники"
CREATE TABLE Employees (
    employee_id INT PRIMARY KEY AUTO_INCREMENT,
    full_name VARCHAR(255) NOT NULL,
    position VARCHAR(100),
    qualification VARCHAR(100),
    hire_date DATE,
    department VARCHAR(100),
    email VARCHAR(100),
    phone VARCHAR(20),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 6. Таблица "Материалы"
CREATE TABLE Materials (
    material_id INT PRIMARY KEY AUTO_INCREMENT,
    material_name VARCHAR(255) NOT NULL,
    material_type VARCHAR(100),
    unit_of_measure VARCHAR(50),
    unit_price DECIMAL(10,2),
    current_stock DECIMAL(10,2) DEFAULT 0,
    min_stock_level DECIMAL(10,2),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 7. Промежуточная таблица для связи M:M "Изделия-Материалы"
CREATE TABLE Product_Materials (
    product_material_id INT PRIMARY KEY AUTO_INCREMENT,
    product_id INT NOT NULL,
    material_id INT NOT NULL,
    quantity_required DECIMAL(10,2) NOT NULL,
    FOREIGN KEY (product_id) REFERENCES Products(product_id) ON DELETE CASCADE,
    FOREIGN KEY (material_id) REFERENCES Materials(material_id) ON DELETE CASCADE,
    UNIQUE KEY unique_product_material (product_id, material_id)
);

-- 8. Таблица "Журнал производства"
CREATE TABLE ProductionLog (
    log_id INT PRIMARY KEY AUTO_INCREMENT,
    project_id INT NOT NULL,
    product_id INT NOT NULL,
    operation_id INT NOT NULL,
    machine_id INT,
    employee_id INT NOT NULL,
    material_id INT,
    start_time DATETIME NOT NULL,
    end_time DATETIME,
    quantity_produced INT DEFAULT 0,
    defects_count INT DEFAULT 0,
    notes TEXT,
    log_date DATE GENERATED ALWAYS AS (DATE(start_time)) STORED,
    duration_hours DECIMAL(5,2) GENERATED ALWAYS AS (
        TIMESTAMPDIFF(MINUTE, start_time, end_time) / 60.0
    ) STORED,
    FOREIGN KEY (project_id) REFERENCES Projects(project_id) ON DELETE CASCADE,
    FOREIGN KEY (product_id) REFERENCES Products(product_id) ON DELETE CASCADE,
    FOREIGN KEY (operation_id) REFERENCES Operations(operation_id),
    FOREIGN KEY (machine_id) REFERENCES Machines(machine_id),
    FOREIGN KEY (employee_id) REFERENCES Employees(employee_id),
    FOREIGN KEY (material_id) REFERENCES Materials(material_id),
    INDEX idx_log_date (log_date),
    INDEX idx_employee_date (employee_id, log_date)
);

-- Комментарии к таблицам
ALTER TABLE Projects COMMENT = 'Таблица производственных проектов/заказов';
ALTER TABLE Products COMMENT = 'Таблица производимых изделий';
ALTER TABLE Operations COMMENT = 'Таблица технологических операций';
ALTER TABLE Machines COMMENT = 'Таблица производственного оборудования';
ALTER TABLE Employees COMMENT = 'Таблица сотрудников предприятия';
ALTER TABLE Materials COMMENT = 'Таблица материалов и сырья';
ALTER TABLE ProductionLog COMMENT = 'Журнал учета выполнения производственных операций';

-- Создание представления для быстрого доступа к данным
CREATE VIEW ProductionOverview AS
SELECT 
    pl.log_id,
    p.project_name,
    pr.product_name,
    o.operation_name,
    e.full_name as employee_name,
    m.machine_name,
    mat.material_name,
    pl.start_time,
    pl.end_time,
    pl.duration_hours,
    pl.quantity_produced,
    pl.defects_count,
    pl.log_date
FROM ProductionLog pl
LEFT JOIN Projects p ON pl.project_id = p.project_id
LEFT JOIN Products pr ON pl.product_id = pr.product_id
LEFT JOIN Operations o ON pl.operation_id = o.operation_id
LEFT JOIN Employees e ON pl.employee_id = e.employee_id
LEFT JOIN Machines m ON pl.machine_id = m.machine_id
LEFT JOIN Materials mat ON pl.material_id = mat.material_id;

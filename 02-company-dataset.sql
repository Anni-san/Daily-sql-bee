
-- SQL MASTERY: COMPANY PRACTICE DATABASE
-- PostgreSQL 17
-- Run this setup script once in sql_mastery.

-- 1. DEPARTMENTS
CREATE TABLE departments (
    department_id INT PRIMARY KEY,
    department_name VARCHAR(60) NOT NULL UNIQUE,
    location VARCHAR(60),
    annual_budget NUMERIC(14, 2)
);

INSERT INTO departments VALUES
(1, 'Engineering', 'Bengaluru', 25000000),
(2, 'Human Resources', 'Delhi', 8000000),
(3, 'Finance', 'Mumbai', 12000000),
(4, 'Sales', 'Pune', 18000000),
(5, 'Marketing', 'Hyderabad', 10000000),
(6, 'Operations', 'Noida', 15000000),
(7, 'IT Support', 'Bengaluru', 9000000),
(8, 'Research', 'Chennai', 22000000),
(9, 'Legal', 'Mumbai', 7000000),
(10, 'Customer Success', 'Noida', 11000000),
(11, 'Data Analytics', 'Hyderabad', 16000000),
(12, 'Product', 'Pune', 20000000);

-- 2. EMPLOYEES
CREATE TABLE employees (
    employee_id INT PRIMARY KEY,
    employee_name VARCHAR(100) NOT NULL,
    email VARCHAR(150) UNIQUE NOT NULL,
    department_id INT REFERENCES departments(department_id),
    salary NUMERIC(12, 2) NOT NULL CHECK (salary > 0),
    joining_date DATE NOT NULL,
    city VARCHAR(60),
    manager_id INT REFERENCES employees(employee_id),
    employment_status VARCHAR(20) NOT NULL
        CHECK (employment_status IN ('Active', 'On Leave', 'Resigned'))
);

INSERT INTO employees (
    employee_id, employee_name, email, department_id,
    salary, joining_date, city, manager_id, employment_status
)
SELECT
    g,
    'Employee ' || LPAD(g::TEXT, 5, '0'),
    'employee' || g || '@example.com',
    ((g - 1) % 12) + 1,
    30000 + ((g * 7919) % 120000),
    DATE '2018-01-01' + ((g * 17) % 3200)::INT,
    (ARRAY[
        'Kanpur', 'Delhi', 'Mumbai', 'Bengaluru',
        'Pune', 'Noida', 'Chennai', 'Hyderabad',
        'Lucknow', 'Jaipur'
    ])[((g - 1) % 10) + 1],
    CASE
        WHEN (g - 1) % 20 = 0 THEN NULL
        ELSE ((g - 1) / 20) * 20 + 1
    END,
    CASE
        WHEN g % 20 = 0 THEN 'Resigned'
        WHEN g % 17 = 0 THEN 'On Leave'
        ELSE 'Active'
    END
FROM generate_series(1, 5000) AS gs(g);

-- 3. PROJECTS
CREATE TABLE projects (
    project_id INT PRIMARY KEY,
    project_name VARCHAR(120) NOT NULL,
    department_id INT REFERENCES departments(department_id),
    start_date DATE NOT NULL,
    end_date DATE,
    project_budget NUMERIC(14, 2),
    project_status VARCHAR(20) NOT NULL
);

INSERT INTO projects
SELECT
    g,
    'Project ' || LPAD(g::TEXT, 4, '0'),
    ((g - 1) % 12) + 1,
    DATE '2022-01-01' + ((g * 11) % 1400)::INT,
    NULL,
    100000 + ((g * 3571) % 5000000),
    CASE
        WHEN g % 5 = 0 THEN 'Completed'
        WHEN g % 5 = 1 THEN 'Planned'
        ELSE 'In Progress'
    END
FROM generate_series(1, 300) AS gs(g);

-- 4. EMPLOYEE-PROJECT ASSIGNMENTS
CREATE TABLE employee_projects (
    employee_id INT REFERENCES employees(employee_id),
    project_id INT REFERENCES projects(project_id),
    assigned_date DATE NOT NULL,
    hours_allocated NUMERIC(6, 2),
    PRIMARY KEY (employee_id, project_id)
);

INSERT INTO employee_projects
SELECT
    e,
    p,
    DATE '2023-01-01' + ((n * 7) % 1200)::INT,
    10 + ((n * 13) % 31)
FROM generate_series(1, 15000) AS gs(n)
CROSS JOIN LATERAL (
    SELECT ((n - 1) % 5000) + 1 AS e,
           ((n - 1) % 300) + 1 AS p
) AS assignment;

-- 5. CUSTOMERS
CREATE TABLE customers (
    customer_id INT PRIMARY KEY,
    customer_name VARCHAR(120) NOT NULL,
    email VARCHAR(150) UNIQUE NOT NULL,
    city VARCHAR(60),
    signup_date DATE NOT NULL,
    customer_type VARCHAR(20)
);

INSERT INTO customers
SELECT
    g,
    'Customer ' || LPAD(g::TEXT, 5, '0'),
    'customer' || g || '@example.com',
    (ARRAY[
        'Kanpur', 'Delhi', 'Mumbai', 'Bengaluru',
        'Pune', 'Noida', 'Chennai', 'Hyderabad',
        'Lucknow', 'Jaipur'
    ])[((g - 1) % 10) + 1],
    DATE '2021-01-01' + ((g * 13) % 2100)::INT,
    CASE
        WHEN g % 10 = 0 THEN 'Enterprise'
        WHEN g % 3 = 0 THEN 'Business'
        ELSE 'Individual'
    END
FROM generate_series(1, 3000) AS gs(g);

-- 6. PRODUCTS
CREATE TABLE products (
    product_id INT PRIMARY KEY,
    product_name VARCHAR(120) NOT NULL,
    category VARCHAR(60),
    price NUMERIC(10, 2) NOT NULL CHECK (price >= 0),
    stock_quantity INT NOT NULL CHECK (stock_quantity >= 0),
    active BOOLEAN NOT NULL DEFAULT TRUE
);

INSERT INTO products
SELECT
    g,
    'Product ' || LPAD(g::TEXT, 4, '0'),
    (ARRAY[
        'Electronics', 'Furniture', 'Clothing',
        'Books', 'Accessories', 'Software'
    ])[((g - 1) % 6) + 1],
    100 + ((g * 137) % 50000),
    (g * 23) % 1000,
    g % 15 <> 0
FROM generate_series(1, 500) AS gs(g);

-- 7. ORDERS
CREATE TABLE orders (
    order_id INT PRIMARY KEY,
    customer_id INT NOT NULL REFERENCES customers(customer_id),
    order_date DATE NOT NULL,
    status VARCHAR(20) NOT NULL,
    total_amount NUMERIC(14, 2) NOT NULL CHECK (total_amount >= 0)
);

INSERT INTO orders
SELECT
    g,
    ((g - 1) % 3000) + 1,
    DATE '2023-01-01' + ((g * 7) % 1350)::INT,
    CASE
        WHEN g % 10 = 0 THEN 'Cancelled'
        WHEN g % 10 = 1 THEN 'Pending'
        WHEN g % 10 = 2 THEN 'Processing'
        ELSE 'Completed'
    END,
    500 + ((g * 187) % 100000)
FROM generate_series(1, 10000) AS gs(g);

-- 8. ORDER ITEMS
CREATE TABLE order_items (
    order_item_id INT PRIMARY KEY,
    order_id INT NOT NULL REFERENCES orders(order_id),
    product_id INT NOT NULL REFERENCES products(product_id),
    quantity INT NOT NULL CHECK (quantity > 0),
    unit_price NUMERIC(10, 2) NOT NULL CHECK (unit_price >= 0)
);

INSERT INTO order_items
SELECT
    g,
    ((g - 1) % 10000) + 1,
    ((g - 1) % 500) + 1,
    ((g - 1) % 5) + 1,
    p.price
FROM generate_series(1, 30000) AS gs(g)
JOIN products p
  ON p.product_id = ((g - 1) % 500) + 1;

-- SETUP COMPLETE

SELECT
    'departments' AS table_name,
    COUNT(*) AS total_rows
FROM departments

UNION ALL

SELECT 'employees', COUNT(*) FROM employees
UNION ALL
SELECT 'projects', COUNT(*) FROM projects
UNION ALL
SELECT 'employee_projects', COUNT(*) FROM employee_projects
UNION ALL
SELECT 'customers', COUNT(*) FROM customers
UNION ALL
SELECT 'products', COUNT(*) FROM products
UNION ALL
SELECT 'orders', COUNT(*) FROM orders
UNION ALL
SELECT 'order_items', COUNT(*) FROM order_items;
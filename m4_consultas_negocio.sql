/*
  Pre-entrega 4 - Data Analytics (Coderhouse)
  Autora: Milagros Gallegos
  Motor: SQL Server 2016 o superior (usa DROP TABLE IF EXISTS)
*/

/*
------------------------ Seccion 1 Creacion DB (pre-entrega anterior)---------------------------------
  Modelo:
  categorias (1) ──── (N) productos (1) ──── (N) ventas (N) ──── (1) clientes
*/

/* PREPARACION: crear la base solo si no existe y posicionarse en ella */

USE master;
GO

IF DB_ID('Ventas_Tech_DB') IS NULL
    CREATE DATABASE Ventas_Tech_DB;
GO

USE Ventas_Tech_DB;
GO

/* SECCION DROP
   Orden inverso a las dependencias (primero las tablas hijas)
   para que el script se pueda ejecutar varias veces sin errores. */

DROP TABLE IF EXISTS ventas;
DROP TABLE IF EXISTS productos;
DROP TABLE IF EXISTS clientes;
DROP TABLE IF EXISTS categorias;
GO

/* SECCION CREATE */

-- Tabla categorias
CREATE TABLE categorias (
    id_categoria     INT          PRIMARY KEY,
    nombre_categoria VARCHAR(50)  NOT NULL,
    descripcion      VARCHAR(200)
);

-- Tabla clientes
CREATE TABLE clientes (
    id_cliente     INT          PRIMARY KEY,
    nombre         VARCHAR(100) NOT NULL,
    email          VARCHAR(100) UNIQUE,
    ciudad         VARCHAR(50),
    fecha_registro DATE         NOT NULL
);

-- Tabla productos
CREATE TABLE productos (
    id_producto     INT           PRIMARY KEY,
    nombre_producto VARCHAR(100)  NOT NULL,
    id_categoria    INT           FOREIGN KEY REFERENCES categorias(id_categoria),
    precio          DECIMAL(10,2) NOT NULL,
    stock           INT           DEFAULT 0,
    activo          BIT           DEFAULT 1
);

-- Tabla ventas
CREATE TABLE ventas (
    id_venta        INT           PRIMARY KEY,
    id_cliente      INT           FOREIGN KEY REFERENCES clientes(id_cliente),
    id_producto     INT           FOREIGN KEY REFERENCES productos(id_producto),
    cantidad        INT           NOT NULL,
    precio_unitario DECIMAL(10,2) NOT NULL,
    fecha_venta     DATE          NOT NULL
);
GO

/* SECCION INSERT
   Orden de las dependencias (primero las tablas padre). */

INSERT INTO categorias (id_categoria, nombre_categoria, descripcion) VALUES
  (1, 'Computación',    'Laptops, PCs y monitores'),
  (2, 'Accesorios',     'Periféricos y complementos'),
  (3, 'Audio',          'Auriculares y parlantes'),
  (4, 'Almacenamiento', 'Discos y memorias');

INSERT INTO clientes (id_cliente, nombre, email, ciudad, fecha_registro) VALUES
  (1, 'María López',  'maria@mail.com',  'Buenos Aires', '2024-01-05'),
  (2, 'Carlos Ruiz',  'carlos@mail.com', 'Córdoba',      '2024-01-10'),
  (3, 'Ana Gómez',    'ana@mail.com',    'Rosario',      '2024-02-01'),
  (4, 'Pedro Sanz',   'pedro@mail.com',  'Mendoza',      '2024-02-15'),
  (5, 'Laura Torres', 'laura@mail.com',  'Tucumán',      '2024-03-01');

INSERT INTO productos (id_producto, nombre_producto, id_categoria, precio, stock, activo) VALUES
  (1, 'Laptop Pro 15',      1, 1200.00, 15, 1),
  (2, 'Mouse Inalámbrico',  2,   28.00, 80, 1),
  (3, 'Monitor 4K 27',      1,  450.00, 12, 1),
  (4, 'Auriculares BT Pro', 3,  120.00, 35, 1),
  (5, 'SSD Externo 1TB',    4,  130.00, 18, 1),
  (6, 'Teclado Mecánico',   2,   95.00, 40, 1);

INSERT INTO ventas (id_venta, id_cliente, id_producto, cantidad, precio_unitario, fecha_venta) VALUES
  ( 1, 1, 1, 2, 1200.00, '2024-03-05'),
  ( 2, 2, 2, 5,   28.00, '2024-03-06'),
  ( 3, 3, 3, 1,  450.00, '2024-03-07'),
  ( 4, 1, 4, 2,  120.00, '2024-03-08'),
  ( 5, 4, 5, 3,  130.00, '2024-03-10'),
  ( 6, 2, 6, 4,   95.00, '2024-03-11'),
  ( 7, 5, 1, 1, 1200.00, '2024-03-12'),
  ( 8, 3, 2, 8,   28.00, '2024-03-13'),
  ( 9, 4, 4, 1,  120.00, '2024-03-14'),
  (10, 5, 3, 2,  450.00, '2024-03-15');
GO

/* SECCION VALIDACION */

-- 1. Contenido de cada tabla
SELECT * FROM categorias;   -- esperado: 4 filas
SELECT * FROM clientes;     -- esperado: 5 filas
SELECT * FROM productos;    -- esperado: 6 filas
SELECT * FROM ventas;       -- esperado: 10 filas

-- 2. Resumen de cantidad de filas por tabla
SELECT 'categorias' AS tabla, COUNT(*) AS filas, 4  AS esperado FROM categorias
UNION ALL
SELECT 'clientes',            COUNT(*),          5              FROM clientes
UNION ALL
SELECT 'productos',           COUNT(*),          6              FROM productos
UNION ALL
SELECT 'ventas',              COUNT(*),          10             FROM ventas;


/*
------------------------ Sección 2 Pre-entrega 4 ---------------------------------
*/

/* Tabla ventas */
SELECT *
FROM ventas

/*
   Consulta 1 - Resumen ejecutivo mensual
   Columnas: id_cliente, id_producto, cantidad, precio_unitario, fecha_venta
*/

SELECT
    SUM(cantidad*precio_unitario) AS total_facturado,
    SUM(cantidad) as cantidad_pedidos,
    AVG(cantidad*precio_unitario) ticket_promedio,
    MONTH(fecha_venta) as mes
FROM ventas
GROUP BY MONTH(fecha_venta)
ORDER BY mes

/*
    Consulta 2 - Ranking de productos
    GROUP BY id_producto, ORDER BY y TOP 5
*/
SELECT TOP 5 id_producto,
    SUM(cantidad*precio_unitario) AS total_facturado,
    SUM(cantidad) as unidades_vendidas
FROM ventas
GROUP BY id_producto
ORDER BY total_facturado DESC

/*
    Consulta 3 - Clientes recurrentes
    GROUP BY id_cliente, HAVING COUNT(*) > 1
*/
SELECT
    id_cliente,
    COUNT(id_cliente) AS cantidad_pedidos,
    SUM(cantidad*precio_unitario) AS total_gastado
FROM ventas
GROUP BY id_cliente
HAVING COUNT(*) > 1

/*
    Consulta 4 - Productos por encima/por debajo del promedio
*/
WITH total_facturado_por_producto AS(
    SELECT
        id_producto,
        SUM(cantidad*precio_unitario) AS total_facturado
    FROM ventas
    GROUP BY id_producto
)
SELECT
    id_producto,
    total_facturado,
    CASE
        WHEN total_facturado > (SELECT AVG(total_facturado) FROM total_facturado_por_producto)
        THEN 'Por encima'
        ELSE 'Por debajo'
    END AS comparacion
FROM total_facturado_por_producto
ORDER BY id_producto




-- Hallazgo 1: El producto 1 tiene facturado el 55.87% del total facturado
-- Hallazgo 2: El producto 4 es el que menos facturó, pero tiene las mismas unidades vendidas que producto 1, 3 y 5
-- Hallazgo 3: El cliente 1 fue el que más ingresos generó

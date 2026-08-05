CREATE DATABASE ExtructurasNF;

USE ExtructurasNF;

-- Creación de la estructura unificada en 1NF 
CREATE TABLE Ventas_1NF (
    id_venta INT NOT NULL,
    nombre_producto VARCHAR(100) NOT NULL,
    fecha_venta DATE NOT NULL,
    nombre_cliente VARCHAR(100) NOT NULL,
    telefono_cliente VARCHAR(20),
    precio_producto DECIMAL(10,2) NOT NULL,
    cantidad INT NOT NULL,
    PRIMARY KEY (id_venta, nombre_producto)
);


-- Creacion de estructura en 2NF

--  Encabezado de Ventas
CREATE TABLE Ventas_Header (
    id_venta INT PRIMARY KEY,
    fecha_venta DATE NOT NULL,
    nombre_cliente VARCHAR(100) NOT NULL,
    telefono_cliente VARCHAR(20)
);

--  Productos
CREATE TABLE Productos_2NF (
    nombre_producto VARCHAR(100) PRIMARY KEY,
    precio_producto DECIMAL(10,2) NOT NULL
);

--  Detalle de Ventas (Relación M:N)
CREATE TABLE Detalle_Ventas_2NF (
    id_venta INT NOT NULL,
    nombre_producto VARCHAR(100) NOT NULL,
    cantidad INT NOT NULL,
    PRIMARY KEY (id_venta, nombre_producto),
    FOREIGN KEY (id_venta) REFERENCES Ventas_Header(id_venta),
    FOREIGN KEY (nombre_producto) REFERENCES Productos_2NF(nombre_producto)
);


-- Creacion de estructura en 3NF

-- 1. Tabla de Clientes
CREATE TABLE Clientes (
    id_cliente INT AUTO_INCREMENT PRIMARY KEY,
    nombre_cliente VARCHAR(100) NOT NULL,
    telefono_cliente VARCHAR(20)
);

-- 2. Tabla de Productos
CREATE TABLE Productos (
    id_producto INT AUTO_INCREMENT PRIMARY KEY,
    nombre_producto VARCHAR(100) NOT NULL,
    precio_producto DECIMAL(10,2) NOT NULL
);

-- 3. Tabla de Ventas (Encabezado)
CREATE TABLE Ventas (
    id_venta INT AUTO_INCREMENT PRIMARY KEY,
    fecha_venta DATE NOT NULL,
    id_cliente INT NOT NULL,
    FOREIGN KEY (id_cliente) REFERENCES Clientes(id_cliente)
);

-- 4. Tabla de Detalle de Ventas
CREATE TABLE Detalle_Ventas (
    id_venta INT NOT NULL,
    id_producto INT NOT NULL,
    cantidad INT NOT NULL,
    PRIMARY KEY (id_venta, id_producto),
    FOREIGN KEY (id_venta) REFERENCES Ventas(id_venta),
    FOREIGN KEY (id_producto) REFERENCES Productos(id_producto)
);



-- Consultas
SELECT 
    v.id_venta AS "ID Venta",
    v.fecha_venta AS "Fecha Venta",
    c.nombre_cliente AS "Nombre Cliente",
    c.telefono_cliente AS "Teléfono Cliente",
    p.nombre_producto AS "Nombre Producto",
    p.precio_producto AS "Precio Producto",
    dv.cantidad AS "Cantidad",
    (p.precio_producto * dv.cantidad) AS "Total"
FROM Ventas v
INNER JOIN Clientes c ON v.id_cliente = c.id_cliente
INNER JOIN Detalle_Ventas dv ON v.id_venta = dv.id_venta
INNER JOIN Productos p ON dv.id_producto = p.id_producto
ORDER BY v.id_venta, p.id_producto;

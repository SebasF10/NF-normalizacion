# Normalización de un conjunto de datos de ventas

## Objetivo

Normalizar paso a paso una estructura de ventas que inicialmente está almacenada en una sola tabla y presenta problemas de redundancia, inconsistencias y dependencias anómalas.

La tabla inicial registra lo siguiente:

- ID de venta
- Fecha de venta
- Nombre del cliente
- Teléfono del cliente
- Nombre del producto
- Precio del producto
- Cantidad
- Total (precio × cantidad)

---

## 1. Problemas de la tabla original y violación a 1NF

La estructura no cumple con la Primera Forma Normal (1NF) porque:

- Los datos no están totalmente atomizados.
- Una misma venta puede contener varios productos, pero el registro está pensado como una sola fila.
- El campo `Total` es un dato derivado y no debe almacenarse como información base.
- La clave primaria no identifica de forma única cada fila si el mismo `id_venta` tiene varios productos.
- Existe redundancia de datos como el nombre y teléfono del cliente en cada registro de venta.

### Indicador de la violación

Si una venta tiene varios productos, la misma venta se repite varias veces con información duplicada, lo que rompe la atomicidad y genera anomalías de actualización.

### Estructura en 1NF

Se reorganiza la información para que cada fila represente una sola venta y un solo producto.

```sql
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
```

### Justificación

En esta etapa:

- Cada registro queda en una fila única.
- Cada atributo contiene valores atómicos.
- La clave compuesta `(id_venta, nombre_producto)` identifica cada registro de forma correcta.

---

## 2. Corrección para cumplir con 2NF

La tabla en 1NF aún presenta dependencias parciales porque parte de la información depende solo de una parte de la clave primaria.

### Problema

En la relación de detalle de venta:

- `id_venta` identifica el encabezado de la venta.
- `nombre_producto` identifica el producto.
- El precio del producto depende únicamente del nombre del producto y no de la venta completa.

Esto significa que existe una dependencia parcial:

- `nombre_producto -> precio_producto`

### Rediseño a 2NF

Se separan las entidades para evitar redundancia:

1. Encabezado de ventas
2. Productos
3. Detalle de ventas

```sql
CREATE TABLE Ventas_Header (
    id_venta INT PRIMARY KEY,
    fecha_venta DATE NOT NULL,
    nombre_cliente VARCHAR(100) NOT NULL,
    telefono_cliente VARCHAR(20)
);

CREATE TABLE Productos_2NF (
    nombre_producto VARCHAR(100) PRIMARY KEY,
    precio_producto DECIMAL(10,2) NOT NULL
);

CREATE TABLE Detalle_Ventas_2NF (
    id_venta INT NOT NULL,
    nombre_producto VARCHAR(100) NOT NULL,
    cantidad INT NOT NULL,
    PRIMARY KEY (id_venta, nombre_producto),
    FOREIGN KEY (id_venta) REFERENCES Ventas_Header(id_venta),
    FOREIGN KEY (nombre_producto) REFERENCES Productos_2NF(nombre_producto)
);
```

### Beneficio

- Se elimina la redundancia del precio del producto en cada detalle de venta.
- La información del producto queda centralizada en una sola tabla.

---

## 3. Corrección para cumplir con 3NF

La estructura en 2NF todavía conserva una dependencia transitiva.

### Problema

El cliente aparece dentro del encabezado de venta, pero sus datos personales (`nombre_cliente` y `telefono_cliente`) no dependen directamente de `id_venta`; dependen del cliente mismo.

Esto genera una dependencia transitiva:

- `id_venta -> id_cliente -> nombre_cliente, telefono_cliente`

### Rediseño a 3NF

Se separa la entidad cliente y la entidad venta.

```sql
CREATE TABLE Clientes (
    id_cliente INT AUTO_INCREMENT PRIMARY KEY,
    nombre_cliente VARCHAR(100) NOT NULL,
    telefono_cliente VARCHAR(20)
);

CREATE TABLE Productos (
    id_producto INT AUTO_INCREMENT PRIMARY KEY,
    nombre_producto VARCHAR(100) NOT NULL,
    precio_producto DECIMAL(10,2) NOT NULL
);

CREATE TABLE Ventas (
    id_venta INT AUTO_INCREMENT PRIMARY KEY,
    fecha_venta DATE NOT NULL,
    id_cliente INT NOT NULL,
    FOREIGN KEY (id_cliente) REFERENCES Clientes(id_cliente)
);

CREATE TABLE Detalle_Ventas (
    id_venta INT NOT NULL,
    id_producto INT NOT NULL,
    cantidad INT NOT NULL,
    PRIMARY KEY (id_venta, id_producto),
    FOREIGN KEY (id_venta) REFERENCES Ventas(id_venta),
    FOREIGN KEY (id_producto) REFERENCES Productos(id_producto)
);
```

### Beneficio

- El cliente queda definido de forma independiente.
- La venta solo guarda el hecho de la transacción y su fecha.
- El detalle de la venta guarda únicamente el producto y la cantidad vendida.

---

## 4. Consulta final con JOIN para reconstruir la información original

Una vez normalizadas las tablas, se puede reconstruir la información completa con una consulta de unión.

```sql
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
```

---

## 5. Resumen final

La normalización aplicada fue:

- 1NF: separó los datos en filas atómicas y estableció una clave adecuada.
- 2NF: eliminó dependencias parciales al separar encabezado, productos y detalle.
- 3NF: eliminó dependencias transitivas al separar clientes de ventas.

Esto permite reducir redundancia, evitar inconsistencias y mantener una estructura más limpia y mantenible.

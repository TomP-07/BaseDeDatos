USE classicmodels;
-- Devuelva la oficina con mayor número de empleados.
SELECT
	officeCode
FROM
	employees
GROUP BY
	officeCode
ORDER BY
	COUNT(employeeNumber) DESC
LIMIT 1;
-- ¿Cuál es el promedio de órdenes hechas por oficina?, ¿Qué oficina vendió la mayor cantidad de productos?
CREATE VIEW offices_orders_amount AS (
SELECT
	e.officeCode,
	COUNT(DISTINCT o.orderNumber) AS orders
FROM
	employees e
JOIN customers c ON
	c.salesRepEmployeeNumber = e.employeeNumber
JOIN orders o ON
	o.customerNumber = c.customerNumber
GROUP BY
	e.officeCode
ORDER BY
	orders DESC);

SELECT
	*
FROM
	offices_orders_amount;

SELECT
	e.officeCode,
	SUM(od.quantityOrdered) AS orders
FROM
	employees e
JOIN customers c ON
	c.salesRepEmployeeNumber = e.employeeNumber
JOIN orders o ON
	o.customerNumber = c.customerNumber
JOIN orderdetails od ON
	od.orderNumber = o.orderNumber
GROUP BY
	e.officeCode
ORDER BY
	orders DESC;
-- Devolver el valor promedio, máximo y mínimo de pagos que se hacen por mes.
SELECT
	max(amount),
	min(amount),
	avg(amount)
FROM
	payments p
GROUP BY
	MONTH(p.paymentDate);
-- Crear un procedimiento "Update Credit" en donde se modifique el límite de crédito de un cliente con un valor pasado por parámetro.
DELIMITER //
CREATE PROCEDURE IF NOT EXISTS update_credit(IN customerNumber INT, IN newCreditLimit INT) BEGIN
	UPDATE
	customers c
SET
	c.creditLimit = newCreditLimit
WHERE
	c.customerNumber = customerNumber;
END //
DELIMITER ;
-- Cree una vista "Premium Customers" que devuelva el top 10 de clientes que más dinero han gastado en la plataforma. La vista deberá devolver el nombre del cliente, la ciudad y el total gastado por ese cliente en la plataforma.

CREATE VIEW premium_customers AS (
SELECT
	c.customerName,
	c.city,
	SUM(p.amount) AS amount_spent
FROM
	customers c
JOIN payments p ON
	c.customerNumber = p.customerNumber
GROUP BY
	c.customerNumber
ORDER BY
	amount_spent DESC
LIMIT 10
);
-- Cree una función "employee of the month" que tome un mes y un año y devuelve el empleado (nombre y apellido) cuyos clientes hayan efectuado la mayor cantidad de órdenes en ese mes.
DELIMITER //
CREATE FUNCTION employee_of_the_month(mnth INT,
yr INT) RETURNS VARCHAR(255) DETERMINISTIC BEGIN
	DECLARE employee varchar(256);

SELECT
	CONCAT(e.firstName, " ", e.lastName)
INTO
	employee
FROM
	employees e
JOIN customers c ON
	c.salesRepEmployeeNumber = e.employeeNumber
JOIN orders o ON
	o.customerNumber = c.customerNumber
WHERE
	MONTH(o.orderDate) = mnth
	AND YEAR(o.orderDate) = yr
GROUP BY
	e.employeeNumber
ORDER BY
	SUM(DISTINCT o.orderNumber) DESC
LIMIT 1;

RETURN employee;
END //
DELIMITER ;

SELECT
	employee_of_the_month(2,
	2003);
-- Crear una nueva tabla "Product Refillment". Deberá tener una relación varios a uno con "products" y los campos: `refillmentID`, `productCode`, `orderDate`, `quantity`.
CREATE TABLE IF NOT EXISTS product_refillment (refillmentID INT AUTO_INCREMENT,
productCode VARCHAR(15),
orderDate DATE,
quantity INT,
PRIMARY KEY(refillmentID));

ALTER TABLE product_refillment ADD FOREIGN KEY (productCode) REFERENCES products(productCode);
-- Definir un trigger "Restock Product" que esté pendiente de los cambios efectuados en `orderdetails` y cada vez que se agregue una nueva orden revise la cantidad de productos pedidos (`quantityOrdered`) y compare con la cantidad en stock (`quantityInStock`) y si es menor a 10 genere un pedido en la tabla "Product Refillment" por 10 nuevos productos.

DROP TRIGGER restock_product;
DELIMITER //
CREATE TRIGGER IF NOT EXISTS restock_product AFTER
INSERT
	ON
	orderdetails FOR EACH ROW BEGIN
		DECLARE diff INT;
		SELECT DISTINCT (p.quantityInStock - NEW.quantityOrdered) AS diff INTO diff FROM products p WHERE p.productCode = NEW.productCode;
		IF (diff < 10) THEN
			INSERT INTO product_refillment (productCode, quantity, orderDate) VALUES (NEW.productCode, 10, curdate());
		END IF;
END //

DELIMITER ;
-- S24_2000
-- SELECT o.orderNumber FROM orders o LIMIT 5;
-- SELECT p.quantityInStock FROM products p WHERE p.productCode = "S24_2000";
-- INSERT INTO orderdetails (orderNumber, productCode, quantityOrdered, priceEach, orderLineNumber) VALUES (10123, "S24_2000", 10, 0, 0);

-- Crear un rol "Empleado" en la BD que establezca accesos de lectura a todas las tablas y accesos de creación de vistas.
CREATE ROLE Empleado;
GRANT SELECT ON classicmodels.* TO Empleado;
GRANT CREATE VIEW ON classicmodels.* TO Empleado;

-- Consultas Adicionales
-- Las siguientes consultas son más difíciles:
-- Encontrar, para cada cliente de aquellas ciudades que comienzan por 'N', la menor y la mayor diferencia en días entre las fechas de sus pagos. No mostrar el id del cliente, sino su nombre y el de su contacto.

-- Encontrar el nombre y la cantidad vendida total de los 10 productos más vendidos que, a su vez, representen al menos el 4% del total de productos, contando unidad por unidad, de todas las órdenes donde intervienen. No utilizar LIMIT.

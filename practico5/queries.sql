USE sakila;

DROP TABLE IF EXISTS directors;
-- Cree una tabla de `directors` con las columnas: Nombre, Apellido, Número de Películas.
CREATE TABLE directors(
	Name varchar(255),
	LastName varchar(255),
	Movies Int,
	PRIMARY KEY (Name,
LastName));
-- El top 5 de actrices y actores de la tabla `actors` que tienen la mayor experiencia (i.e. el mayor número de películas filmadas) son también directores de las películas en las que participaron. Basados en esta información, inserten, utilizando una subquery los valores correspondientes en la tabla `directors`.

INSERT
	INTO
	directors
SELECT
	a.first_name AS Name,
	a.last_name AS LastName,
	count(fa.film_id) AS Movies
FROM
	actor a
INNER JOIN film_actor fa ON
	a.actor_id = fa.actor_id
GROUP BY
	(a.actor_id)
ORDER BY
	Movies DESC
LIMIT 5;
-- Agregue una columna `premium_customer` que tendrá un valor 'T' o 'F' de acuerdo a si el cliente es "premium" o no. Por defecto ningún cliente será premium.
-- UPDATE customer SET customer.premium_customer = "F";
-- ALTER TABLE customer DROP COLUMN premium_customer;

ALTER TABLE customer ADD COLUMN premium_customer CHAR DEFAULT "F";

ALTER TABLE customer ADD CHECK (customer.premium_customer = "T"
	OR customer.premium_customer = "F");
-- Modifique la tabla customer. Marque con 'T' en la columna `premium_customer` de los 10 clientes con mayor dinero gastado en la plataforma.
UPDATE
	customer
SET
	premium_customer = "T"
WHERE
	customer.customer_id IN (
	SELECT
		*
	FROM
		(
		SELECT
			c.customer_id
		FROM
			customer c
		INNER JOIN payment p ON
			c.customer_id = p.customer_id
		GROUP BY
			c.customer_id
		ORDER BY
			SUM(p.amount) DESC
		LIMIT 10
		) top10);
-- Listar, ordenados por cantidad de películas (de mayor a menor), los distintos ratings de las películas existentes (Hint: rating se refiere en este caso a la clasificación según edad: G, PG, R, etc).
SELECT
	f.rating,
	COUNT(f.film_id) AS `film_count`
FROM
	film f
GROUP BY
	f.rating
ORDER BY
	`film_count` DESC;
-- ¿Cuáles fueron la primera y última fecha donde hubo pagos?
SELECT
	MIN(p.payment_date) AS "Fecha primer pago",
	MAX(p.payment_date) AS "Fecha ultimo pago"
FROM
	payment p;
-- Calcule, por cada mes, el promedio de pagos (Hint: vea la manera de extraer el nombre del mes de una fecha).
SELECT
	MONTHNAME(p.payment_date) AS `Mes`,
	AVG(p.amount) AS `Promedio de pagos`
FROM
	payment p
GROUP BY
	`Mes`;
-- Listar los 10 distritos que tuvieron mayor cantidad de alquileres (con la cantidad total de alquileres).
SELECT
	a.district,
	COUNT(r.rental_id) AS `Alquileres`
FROM
	address a
JOIN customer c ON
	a.address_id = c.address_id
JOIN rental r ON
	r.customer_id = c.customer_id
GROUP BY
	a.district
ORDER BY
	`Alquileres` DESC
LIMIT 10;
-- Modifique la table `inventory_id` agregando una columna `stock` que sea un número entero y representa la cantidad de copias de una misma película que tiene determinada tienda. El número por defecto debería ser 5 copias.
-- ALTER TABLE inventory DROP COLUMN stock;

ALTER TABLE inventory ADD COLUMN stock Int DEFAULT 5;
-- Cree un trigger `update_stock` que, cada vez que se agregue un nuevo registro a la tabla rental, haga un update en la tabla `inventory` restando una copia al stock de la película rentada (Hint: revisar que el rental no tiene información directa sobre la tienda, sino sobre el cliente, que está asociado a una tienda en particular).
CREATE TRIGGER IF NOT EXISTS update_Stock AFTER
INSERT
	ON
	rental FOR EACH ROW
UPDATE
	inventory
SET
	stock = stock - 1
WHERE
	inventory_id = nrow.inventory_id;
-- Cree una tabla `fines` que tenga dos campos: `rental_id` y `amount`. El primero es una clave foránea a la tabla rental y el segundo es un valor numérico con dos decimales.
DROP TABLE IF EXISTS fines;

CREATE TABLE fines(
	rental_id Int,
	amount Numeric(10,
2)
);

ALTER TABLE fines ADD FOREIGN KEY (rental_id) REFERENCES rental(rental_id);
-- Cree un procedimiento `check_date_and_fine` que revise la tabla `rental` y cree un registro en la tabla `fines` por cada `rental` cuya devolución (return_date) haya tardado más de 3 días (comparación con rental_date). El valor de la multa será el número de días de retraso multiplicado por 1.5.

-- DROP PROCEDURE check_date_and_fine;

DELIMITER //
CREATE PROCEDURE IF NOT EXISTS check_date_and_fine()
BEGIN
	INSERT INTO fines (SELECT r.rental_id, DATEDIFF(r.return_date, r.rental_date) * 1.5 AS amount FROM rental r WHERE DATEDIFF(r.return_date, r.rental_date) > 3);
END //
DELIMITER ;

;

CALL check_date_and_fine();
-- Crear un rol `employee` que tenga acceso de inserción, eliminación y actualización a la tabla `rental`.
CREATE ROLE IF NOT EXISTS employee;
GRANT INSERT, DELETE, UPDATE ON rental TO employee


-- Revocar el acceso de eliminación a `employee` y crear un rol `administrator` que tenga todos los privilegios sobre la BD `sakila`.
REVOKE DELETE ON rental FROM employee;
CREATE ROLE IF NOT EXISTS administrator;
GRANT ALL PRIVILEGES ON sakila TO administrator;
-- Crear dos roles de empleado. A uno asignarle los permisos de `employee` y al otro de `administrator`.
CREATE ROLE IF NOT EXISTS mortal_employee;
CREATE ROLE IF NOT EXISTS boss_employee;
GRANT employee TO mortal_employee;
GRANT administrator TO boss_employee;
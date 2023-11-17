USE olympics;

-- 1. Crear un campo nuevo `total_medals` en la tabla `person` que almacena la cantidad de medallas ganadas por cada persona. Por defecto, con valor 0.

ALTER TABLE person ADD COLUMN total_medals INT DEFAULT 0;

-- 2. Actualizar la columna  `total_medals` de cada persona con el recuento real de medallas que ganó. Por ejemplo, para Michael Fred Phelps II, luego de la actualización debería tener como valor de `total_medals` igual a 28.

UPDATE
	person p
SET
	total_medals = (
	SELECT
		COUNT(ce.event_id) AS total_medals
	FROM
		games_competitor gc
	INNER JOIN competitor_event ce ON
		gc.id = ce.competitor_id
	INNER JOIN medal m ON
		m.id = ce.medal_id
		AND
		m.medal_name NOT LIKE "NA"
	WHERE
		gc.person_id = p.id
);

-- Query para testear:
-- SELECT * FROM person p WHERE p.id = 94406;

-- 3. Devolver todos los medallistas olímpicos de Argentina, es decir, los que hayan logrado alguna medalla de oro, plata, o bronce, enumerando la cantidad por tipo de medalla.  Por ejemplo, la query debería retornar casos como el siguiente: (Juan Martín del Potro, Bronze, 1), (Juan Martín del Potro, Silver,1)

SELECT
	p.full_name,
	m.medal_name,
	COUNT(m.medal_name) AS medal_count
FROM
	person p
INNER JOIN games_competitor gc
	ON
	gc.person_id = p.id
INNER JOIN competitor_event ce
	ON
	ce.competitor_id = gc.id
INNER JOIN medal m
	ON
	ce.medal_id = m.id
	AND m.medal_name NOT LIKE "NA"
INNER JOIN person_region pr
ON
	pr.person_id = p.id
INNER JOIN noc_region r
ON
	r.id = pr.region_id
WHERE
	r.region_name = "Argentina"
GROUP BY
	p.full_name,
	m.medal_name;

-- 4. Listar el total de medallas ganadas por los deportistas argentinos en cada deporte.

-- Comentario: Hay ciertos deportitas argentinos que no tienen deportes asociados y por ende no van a ser mostrados.

SELECT
	p.full_name,
	s.sport_name,
	COUNT(m.id) AS medal_count
FROM
	person p
INNER JOIN games_competitor gc
	ON
	gc.person_id = p.id
INNER JOIN competitor_event ce
	ON
	ce.competitor_id = gc.id
INNER JOIN medal m
	ON
	ce.medal_id = m.id
	AND m.medal_name NOT LIKE "NA"
INNER JOIN event e
ON
	ce.event_id = e.id
INNER JOIN sport s
ON
	e.id = s.id
INNER JOIN person_region pr
ON
	pr.person_id = p.id
INNER JOIN noc_region r
ON
	r.id = pr.region_id
WHERE
	r.region_name = "Argentina"
GROUP BY
	p.full_name,
	s.sport_name;

-- 5. Listar el número total de medallas de oro, plata y bronce ganadas por cada país (país representado en la tabla `noc_region`), agruparlas los resultados por pais.

-- Para evitar duplicar mucho se hace esta view que resuelve este ejercicio y es usada en el ejercicio siguiente.

CREATE VIEW medals_for_country AS
SELECT
	r.region_name AS "country",
	m.medal_name,
	COUNT(m.medal_name) AS amount
FROM
	noc_region r
INNER JOIN person_region pr ON
	r.id = pr.region_id
INNER JOIN person p ON
	pr.person_id = p.id
INNER JOIN games_competitor gc ON
	gc.person_id = p.id
INNER JOIN competitor_event ce ON
	ce.competitor_id = gc.id
INNER JOIN medal m ON
	ce.medal_id = m.id
	AND m.medal_name != "NA"
GROUP BY
	r.region_name,
	m.medal_name;


SELECT * FROM medals_for_country;

-- 6. Listar el país con más y menos medallas ganadas en la historia de las olimpiadas. 
(
SELECT
	country,
	SUM(amount) AS `Total medals`
FROM medals_for_country GROUP BY country ORDER BY `Total medals` DESC LIMIT 1
)
UNION 
(
SELECT
	country,
	SUM(amount) AS `Total medals`
FROM medals_for_country GROUP BY country ORDER BY `Total medals` ASC LIMIT 1 
);

-- 7. Crear dos triggers:
-- Un trigger llamado `increase_number_of_medals` que incrementará en 1 el valor del campo `total_medals` de la tabla `person`.
-- Un trigger llamado `decrease_number_of_medals` que decrementará en 1 el valor del campo `totals_medals` de la tabla `person`.
-- El primer trigger se ejecutará luego de un `INSERT` en la tabla `competitor_event` y deberá actualizar el valor en la tabla `person` de acuerdo al valor introducido (i.e. sólo aumentará en 1 el valor de `total_medals` para la persona que ganó una medalla). Análogamente, el segundo trigger se ejecutará luego de un `DELETE` en la tabla `competitor_event` y sólo actualizará el valor en la persona correspondiente.

-- DROP TRIGGER increase_number_of_medals;
DELIMITER //
CREATE TRIGGER IF NOT EXISTS increase_number_of_medals AFTER
INSERT ON competitor_event FOR EACH ROW BEGIN 
	SELECT m.medal_name INTO @m_name FROM medal m WHERE m.id = NEW.medal_id;
	IF @m_name NOT LIKE "NA" THEN
		SELECT p.id INTO @person_id FROM person p INNER JOIN games_competitor gc ON p.id = gc.person_id 
WHERE gc.id = NEW.competitor_id;
		UPDATE person p SET	p.total_medals = p.total_medals + 1 WHERE p.id = @person_id;
	END IF;
END //
DELIMITER ;

-- DROP TRIGGER decrease_number_of_medals;
DELIMITER //
CREATE TRIGGER IF NOT EXISTS decrease_number_of_medals AFTER
DELETE ON competitor_event FOR EACH ROW BEGIN 
	SELECT m.medal_name INTO @m_name FROM medal m WHERE m.id = OLD.medal_id;
	IF @m_name NOT LIKE "NA" THEN
		SELECT p.id INTO @person_id FROM person p INNER JOIN games_competitor gc ON p.id = gc.person_id 
WHERE gc.id = OLD.competitor_id;
		UPDATE person p SET	p.total_medals = p.total_medals - 1 WHERE p.id = @person_id;
	END IF;
END //
DELIMITER ;


-- Queries de Test:
-- INSERT INTO competitor_event VALUES(1, 125108, 1);
-- DELETE FROM competitor_event ce WHERE ce.competitor_id = 125108 AND ce.event_id = 1 LIMIT 1;
-- SELECT * FROM person p WHERE p.id = 94406;

-- 8. Crear un procedimiento  `add_new_medalists` que tomará un `event_id`, y tres ids de atletas `g_id`, `s_id`, y `b_id` donde se deberá insertar tres registros en la tabla `competitor_event`  asignando a `g_id` la medalla de oro, a `s_id` la medalla de plata, y a `b_id` la medalla de bronce.

DELIMITER //
CREATE PROCEDURE add_new_medalists(IN event_id INT, IN g_id INT, IN s_id INT, IN b_id INT) BEGIN
	SET @gold_id = NULL;
	SET @silver_id = NULL;
	SET @bronze_id = NULL;
	SELECT m.id INTO @gold_id FROM medal m WHERE m.medal_name LIKE "Gold";
	SELECT m.id INTO @silver_id FROM medal m WHERE m.medal_name LIKE "Silver";
	SELECT m.id INTO @bronze_id FROM medal m WHERE m.medal_name LIKE "Bronze";

	INSERT INTO competitor_event VALUES (event_id, g_id, @gold_id);
	INSERT INTO competitor_event VALUES (event_id, s_id, @silver_id);
	INSERT INTO competitor_event VALUES (event_id, b_id, @bronze_id);
END //
DELIMITER ;


-- 9. Crear el rol `organizer` y asignarle permisos de eliminación sobre la tabla `games` y permiso de actualización sobre la columna `games_name`  de la tabla `games` .

CREATE ROLE organizer;

GRANT DELETE ON games TO organizer;

GRANT UPDATE (games_name) ON olympics.games TO organizer;

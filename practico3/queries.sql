USE world;
-- Lista el nombre de la ciudad, nombre del país, región y forma de gobierno de las 10 ciudades más pobladas del mundo.
SELECT
	city.Name,
	country.Name,
	country.Region,
	country.GovernmentForm
FROM
	city
INNER JOIN country ON
	city.CountryCode = country.Code
ORDER BY
	city.Population DESC
LIMIT 10;
-- Listar los 10 países con menor población del mundo, junto a sus ciudades capitales (Hint: puede que uno de estos países no tenga ciudad capital asignada, en este caso deberá mostrar "NULL").
SELECT
	country.Name,
	city.Name AS "Capital"
FROM
	country
LEFT JOIN city ON
	city.ID = country.Capital
ORDER BY
	country.Population ASC
LIMIT 10;
-- Listar el nombre, continente y todos los lenguajes oficiales de cada país. (Hint: habrá más de una fila por país si tiene varios idiomas oficiales).
SELECT
	ct.Name,
	ct.Continent,
	lang.Language
FROM
	country ct
INNER JOIN countrylanguage lang ON
	lang.CountryCode = ct.Code
WHERE
	lang.IsOfficial LIKE "T";
-- Listar el nombre del país y nombre de capital, de los 20 países con mayor superficie del mundo.
SELECT
	ct.Name,
	city.Name as "Capital"
FROM
	country ct
LEFT JOIN city ON
	ct.Capital = city.ID
ORDER BY
	ct.SurfaceArea DESC
LIMIT 20;
-- Listar las ciudades junto a sus idiomas oficiales (ordenado por la población de la ciudad) y el porcentaje de hablantes del idioma.
SELECT
	city.Name,
	cl.Language,
	cl.Percentage
FROM
	city
INNER JOIN countrylanguage cl ON
	city.CountryCode = cl.CountryCode
WHERE
	cl.IsOfficial LIKE "T"
ORDER BY
	city.Population DESC;
-- Listar los 10 países con mayor población y los 10 países con menor población (que tengan al menos 100 habitantes) en la misma consulta.
(
SELECT
	ct.Name,
	ct.Population
FROM
	country ct
ORDER BY
	ct.Population DESC
LIMIT 10)
UNION (
SELECT
ct.Name,
ct.Population
FROM
country ct
WHERE
ct.Population >= 100
ORDER BY
ct.Population ASC
LIMIT 10);
-- Listar aquellos países cuyos lenguajes oficiales son el Inglés y el Francés (hint: no debería haber filas duplicadas).

SELECT
	c.Name
FROM
	countrylanguage cl
JOIN country c
ON
	cl.CountryCode = c.Code
WHERE
	cl.`Language` LIKE "French"
	AND cl.IsOfficial like "T"
INTERSECT 
SELECT
	c.Name
FROM
	countrylanguage cl
JOIN country c
ON
	cl.CountryCode = c.Code
WHERE
	cl.`Language` LIKE "English"
	AND cl.IsOfficial like "T";
-- Listar aquellos países que tengan hablantes del Inglés pero no del Español en su población.
SELECT
	c.Name
FROM
	country c
INNER JOIN countrylanguage cl ON
	cl.CountryCode = c.Code
WHERE
	cl.Language LIKE "English"
	AND cl.Percentage > 0
EXCEPT
SELECT
	c.Name
FROM
	country c
INNER JOIN countrylanguage cl on
	cl.CountryCode = c.Code
WHERE
	cl.Language LIKE "SPANISH"
	AND cl.Percentage > 0;
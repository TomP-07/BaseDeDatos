USE world;
-- Listar el nombre de la ciudad y el nombre del país de todas las ciudades que pertenezcan a países con una población menor a 10000 habitantes.
SELECT
	city.Name AS "City",
	c.Name AS "Country",	
	c.Population
FROM
	city
INNER JOIN country c ON
	city.CountryCode = c.Code
WHERE
	city.CountryCode IN (
	SELECT
		Code
	FROM
		country c
	WHERE
		c.Population < 10000);

-- Listar todas aquellas ciudades cuya población sea mayor que la población promedio entre todas las ciudades.
SELECT city.Name FROM city WHERE city.Population > (SELECT AVG(c2.Population) FROM city c2);

-- Listar todas aquellas ciudades no asiáticas cuya población sea igual o mayor a la población total de algún país de Asia.
SELECT
	city.Name
FROM
	city
INNER JOIN country c ON
	city.CountryCode = c.Code
WHERE
	c.Continent NOT LIKE "Asia"
	AND city.Population >= SOME (
	SELECT
		Population
	FROM
		country
	WHERE
		country.Continent LIKE "Asia"); -- Se puede hacer >= al minimo
-- Listar aquellos países junto a sus idiomas no oficiales, que superen en porcentaje de hablantes a cada uno de los idiomas oficiales del país.
SELECT
	c.Name,
	GROUP_CONCAT(cl.Language) AS "Official Languages" 
FROM
	country c
INNER JOIN countrylanguage cl ON
	c.Code = cl.CountryCode
WHERE
	cl.IsOfficial LIKE "F"
	AND cl.Percentage > ALL (
	SELECT
		cl2.Percentage
	FROM
		countrylanguage cl2
	WHERE
		cl2.CountryCode = c.Code
		AND
		cl2.IsOfficial LIKE "T")
GROUP BY c.Code;
-- Listar (sin duplicados) aquellas regiones que tengan países con una superficie menor a 1000 km2 y exista (en el país) al menos una ciudad con más de 100000 habitantes. (Hint: Esto puede resolverse con o sin una subquery, intenten encontrar ambas respuestas).
-- Opcion con Subquery:
SELECT DISTINCT 
	c.Region
FROM
	country c
WHERE
	c.SurfaceArea < 1000
	AND EXISTS (
	SELECT
		*
	FROM
		city
	WHERE
		city.Population > 100000
		AND city.CountryCode = c.Code);
	
-- Opcion sin Subquery:
	
SELECT
	DISTINCT c.Region
FROM
	country c
INNER JOIN city ON
	city.CountryCode = c.Code
WHERE
	c.SurfaceArea < 1000
	AND city.Population > 100000;
-- Listar el nombre de cada país con la cantidad de habitantes de su ciudad más poblada. (Hint: Hay dos maneras de llegar al mismo resultado. Usando consultas escalares o usando agrupaciones, encontrar ambas).
-- Con Agrupacion:
SELECT
	c.Name,
	MAX(city.Population) AS `Habitantes de la ciudad mas poblada`
FROM
	country c INNER JOIN city ON
	city.CountryCode = c.Code
GROUP BY
	c.Code
ORDER BY c.Name;

-- Con consultas escalares:
SELECT
	c.Name,
	(
	SELECT
		city.Population
	FROM
		city
	WHERE
		city.CountryCode = c.Code
	ORDER BY
		city.Population DESC
	LIMIT 1) AS `Habitantes de la ciudad mas poblada`
FROM
	country c
HAVING `Habitantes de la ciudad mas poblada` IS NOT NULL
ORDER BY
	c.Name;



-- Listar aquellos países y sus lenguajes no oficiales cuyo porcentaje de hablantes sea mayor al promedio de hablantes de los lenguajes oficiales.
SELECT
	c.Name,
	cl.Language
FROM
	country c
INNER JOIN countrylanguage cl ON
	cl.CountryCode = c.Code
WHERE
	cl.IsOfficial LIKE "F"
	AND cl.Percentage > (
	SELECT
		AVG(cl2.Percentage)
	FROM
		countrylanguage cl2
	WHERE
		cl2.CountryCode = c.Code
		AND cl.IsOfficial LIKE "T");
-- Listar la cantidad de habitantes por continente ordenado en forma descendente.
SELECT
	c.Continent,
	SUM(c.Population) AS `Habitantes`
FROM
	country c
GROUP BY
	c.Continent
ORDER BY
	`Habitantes` DESC; 
-- Listar el promedio de esperanza de vida (LifeExpectancy) por continente con una esperanza de vida entre 40 y 70 años.
SELECT
	c.Continent,
	AVG(c.LifeExpectancy) AS `Life Expectancy`
FROM
	country c
GROUP BY
	c.Continent
HAVING `Life Expectancy` BETWEEN 40 and 70;

-- Listar la cantidad máxima, mínima, promedio y suma de habitantes por continente.
SELECT
	c.Continent,
	MAX(c.Population) AS `Max Population`,
	MIN(c.Population) AS `Min Population`,
	AVG(c.Population) AS `Average Population`,
	SUM(c.Population) AS `Sum Population`
FROM
	country c
GROUP BY
	c.Continent;  

























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
-- Listar el nombre, continente y todos los lenguajes oficiales de cada país. (Hint: habrá más de una fila por país si tiene varios idiomas oficiales).
-- Listar el nombre del país y nombre de capital, de los 20 países con mayor superficie del mundo.
-- Listar las ciudades junto a sus idiomas oficiales (ordenado por la población de la ciudad) y el porcentaje de hablantes del idioma.
-- Listar los 10 países con mayor población y los 10 países con menor población (que tengan al menos 100 habitantes) en la misma consulta.
-- Listar aquellos países cuyos lenguajes oficiales son el Inglés y el Francés (hint: no debería haber filas duplicadas).
-- Listar aquellos países que tengan hablantes del Inglés pero no del Español en su población.
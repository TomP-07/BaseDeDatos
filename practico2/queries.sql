USE world;

-- Devuelva una lista de los nombres y las regiones a las que pertenece cada país ordenada alfabéticamente.
SELECT Name, Region FROM country ORDER BY Name ASC, Region ASC;

-- Liste el nombre y la población de las 10 ciudades más pobladas del mundo.
SELECT Name, Population FROM city ORDER BY Population DESC LIMIT 10;

-- Liste el nombre, región, superficie y forma de gobierno de los 10 países con menor superficie.
SELECT Name, Region, SurfaceArea, GovernmentForm FROM country ORDER BY SurfaceArea ASC LIMIT 10;

-- Liste todos los países que no tienen independencia
SELECT Name FROM country WHERE IndepYear IS NULL;

-- Liste el nombre y el porcentaje de hablantes que tienen todos los idiomas declarados oficiales.
SELECT Language, Percentage FROM countrylanguage lang WHERE lang.IsOfficial LIKE "T";
use("mflix");
db.runCommand({
  collMod: "movies",
  validator: {
    $jsonSchema: {
      bsonType: "object",
      required: ["title", "year"],
      properties: {
        title: {
          bsonType: "string",
          description: "title is required",
        },
        year: {
          bsonType: "int",
          description: "year is required and 1900 <= year <= 3000",
          minimum: 1900,
          maximum: 3000,
        },
        cast: {
          bsonType: "array",
          description: "cast must be an array of strings without duplicates",
          uniqueItems: true,
          items: {
            bsonType: "string",
            description: "Array element must be an string",
          },
        },
        directors: {
          bsonType: "array",
          description:
            "directors must be an array of strings without duplicates",
          uniqueItems: true,
          items: {
            bsonType: "string",
            description: "Array element must be an string",
          },
        },
        countries: {
          bsonType: "array",
          description:
            "countries must be an array of strings without duplicates",
          uniqueItems: true,
          items: {
            bsonType: "string",
            description: "Array element must be an string",
          },
        },
        genres: {
          bsonType: "array",
          description: "genres must be an array of strings without duplicates",
          uniqueItems: true,
          items: {
            bsonType: "string",
            description: "Array element must be an string",
          },
        },
      },
    },
  },
});

db.movies.insertOne({
  title: "Some Movie",
  year: NumberInt(1900),
  directors: ["Test1", "Test2"],
});

db.movies.deleteMany({
  title: "Some Movie",
});

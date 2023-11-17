use("mflix");
db.runCommand({
  collMod: "theaters",
  validationAction: "warn",
  validator: {
    $jsonSchema: {
      bsonType: "object",
      required: ["theaterId", "location"],
      properties: {
        theaterId: {
          bsonType: "int",
          description: "theaterId is required",
        },
        location: {
          bsonType: "object",
          description: "location is required",
          required: ["address"],
          properties: {
            address: {
              bsonType: "object",
              required: ["street1", "city", "state", "zipcode"],
              properties: {
                street1: {
                  bsonType: "string",
                  description: "street1 is required.",
                },
                city: {
                  bsonType: "string",
                  description: "city is required.",
                },
                state: {
                  bsonType: "string",
                  description: "state is required.",
                },
                zipcode: {
                  bsonType: "string",
                  description: "zipcode is required.",
                },
              },
            },
            geo: {
              bsonType: "object",
              required: ["type", "coordinates"],
              properties: {
                type: {
                  enum: ["Point", null],
                  description: "type is required.",
                },
                coordinates: {
                  bsonType: "array",
                  maxItems: 2,
                  minItems: 2,
                  items: {
                    bsonType: "double",
                    description: "coordinate item must be a double.",
                  },
                  description: "coordinates is required",
                },
              },
            },
          },
        },
      },
    },
  },
});

db.theaters.insertOne({
  theaterId: 51,
  location: {
    address: {
      street1: "Test",
      city: "Test",
      state: "Test",
      zipcode: "Test",
    },
    geo: {
      type: "Point",
      coordinates: [2.01, 3.2],
    },
  },
});

db.theaters.deleteMany({
  theaterId: 51,
});

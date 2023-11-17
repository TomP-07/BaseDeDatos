use("mflix");
db.createCollection("userProfiles", {
  validator: {
    $jsonSchema: {
      bsonType: "object",
      required: ["user_id", "language"],
      properties: {
        user_id: {
          bsonType: "objectId",
          description: "user_id is required and must be of type objectId",
        },
        language: {
          enum: ["English", "Spanish", "Portuguese"],
          description:
            "language is required and must be one of: English, Spanish or Portuguese",
        },
        favorite_genres: {
          bsonType: "array",
          uniqueItems: true,
          description: "favorite_genres must be an array of unique items",
          items: {
            bsonType: "string",
            description: "Array element must be of type string",
          },
        },
      },
    },
  },
});

// db.userProfiles.insertOne({
//   user_id: ObjectId(),
//   language: "Spanish",
//   favorite_genres: ["Test1", "Test2"],
// });

// db.userProfiles.deleteMany({
//   language: "Spanish",
// });

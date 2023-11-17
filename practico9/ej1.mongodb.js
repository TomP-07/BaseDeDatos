use("mflix");
db.runCommand({
  collMod: "users",
  validator: {
    $jsonSchema: {
      bsonType: "object",
      required: ["name", "email", "password"],
      properties: {
        name: {
          bsonType: "string",
          maxLength: 30,
          description:
            "name must have max length of 30 characters and is required",
        },
        email: {
          bsonType: "string",
          pattern: "^(.*)@(.*)\\.(.{2,4})$",
          description: "Email is required and should match the email format",
        },
        password: {
          bsonType: "string",
          minLength: 50,
          description:
            "Password is required and should be of at least 50 characters",
        },
      },
    },
  },
});

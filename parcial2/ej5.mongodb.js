use("supplies");

// Actualizamos el esquema de validacion:
// Aclaracion: Me colgue y hice todo el esquema completo en vez de los campos selectos
// dados en el enunciado, asi que quedaron mas campos de los solicitados:
db.runCommand({
  collMod: "sales",
  validator: {
    $jsonSchema: {
      bsonType: "object",
      required: [
        "_id",
        "saleDate",
        "items",
        "storeLocation",
        "customer",
        "couponUsed",
        "purchaseMethod",
      ],
      properties: {
        _id: {
          bsonType: "objectId",
          description: "La ID de la venta es requerida", // Mongo ya fuerza el _id y lo genera automaticamente pero lo dejo explicito
        },
        saleDate: {
          bsonType: "date",
          description: "La fecha de la venta es requerida",
        },
        items: {
          bsonType: "array",
          minItems: 1,
          items: {
            bsonType: "object",
            required: ["name", "tags", "price", "quantity"],
            properties: {
              name: {
                bsonType: "string",
                description: "El nombre del producto es requerido",
              },
              tags: {
                bsonType: "array",
                description: "La lista de tags es requerida",
              },
              price: {
                bsonType: "decimal",
                description: "El precio del producto es requerido",
              },
              quantity: {
                bsonType: "int",
                minimum: 1,
                description:
                  "La cantidad del producto es requerida y debe ser almenos 1",
              },
            },
          },
          description:
            "La lista de productos vendidos es requerida, y a su vez debe tener almenos un producto",
        },
        storeLocation: {
          bsonType: "string",
          description: "El lugar de la tienda es requerido",
        },
        customer: {
          bsonType: "object",
          required: ["email", "age", "gender"], // Consideramos a la satisfacion como NO requerida
          properties: {
            email: {
              bsonType: "string",
              pattern: "^(.*)@(.*)\\.(.{2,4})$", // Usamos la exprension regular dada en el practico 7 de la materia por simplicidad
              description: "El email es requerido y debe tener dicho formato",
            },
            age: {
              bsonType: "int",
              minimum: 6, // No se supone que haya un customer con edad menor a 6 años (y probablemente deberia de ser mas)
              description: "La edad es requerida y debe ser mayor a 6",
            },
            gender: {
              enum: ["M", "F"],
              description: "El genero debe ser 'M' o 'F'",
            },
            satisfaction: {
              bsonType: "int",
              minimum: 1,
              maximum: 5,
              description: "La satisfaccion debe ser un entero entre 1 y 5",
            },
          },
        },
        couponUsed: {
          bsonType: "bool",
          description: "Se debe especificar si se uso un cupon o no",
        },
        purchaseMethod: {
          enum: ["Online", "Phone", "In store"], // Asumo estas formas de compra a partir de los datos almacenados
          description:
            "El metodo de compra debe ser uno de los siguientes: 'Online', 'Phone' o 'In store'",
        },
      },
    },
  },
});

// Caso de test exitoso:
db.sales.insertOne({
  storeLocation: "SomeUnknownLocation",
  saleDate: ISODate("2023-01-01T13:05:00.000+00:00"),
  items: [
    {
      name: "NASA",
      tags: [],
      price: Decimal128("123132.231"),
      quantity: 1,
    },
  ],
  customer: {
    age: 21,
    gender: "M",
    email: "someemail@mail.com",
    satisfaction: 5,
  },
  couponUsed: true,
  purchaseMethod: "Online",
});
// Removes el elemento insertado para testear:
db.sales.deleteOne({
  storeLocation: "SomeUnknownLocation",
});

// Caso de test fallido: (El email es invalido)
db.sales.insertOne({
  storeLocation: "SomeUnknownLocation",
  saleDate: ISODate("2023-01-01T13:05:00.000+00:00"),
  items: [
    {
      name: "NASA",
      tags: [],
      price: Decimal128("123132.231"),
      quantity: 1,
    },
  ],
  customer: {
    age: 21,
    gender: "M",
    email: "wrongemail",
    satisfaction: 5,
  },
  couponUsed: true,
  purchaseMethod: "Online",
});

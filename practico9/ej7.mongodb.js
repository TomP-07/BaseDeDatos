/*
 * Una “consulta es eficiente” si se puede responder en un sola query sin $lookup
 * Se determina el esquema a partir de las consultas que se requieren realizar:
 *
 * Query 1: Listar el id, titulo, y precio de los libros y sus categorías de un autor en particular
 * => Documentos anidado, considerar un libro y adentro un documento anidado representando categories
 * Query 2: Cantidad de libros por categorías
 * => Se hace super eficiente aplicando la idea anterior
 * Query 3: Listar el nombre y dirección entrega y el monto total (quantity * price) de sus pedidos para un order_id dado.
 * => Esto depende de cuantas order_details tengamos para una orden dada.
 *    Si son menos de N=1000 entonces optamos por una lista de documentos anidados, dado que el tamaño de un documento
 *    de order_detail multiplicado por 1000 no va a superar el limite de 16MB de un document order
 *
 *    Si son mas de N=1000 pero menor a N=100000 optamos por hacer one-to-many por referencias, dado que un ObjectId
 *    es de tamaño de 12 bytes, 12B * 100000 < 16 MB, y por ende podemos poner todas las referencias en order
 *
 *    Si son mas N=100000 optamos por hacer one-to-squillon aplicamos el patron parent-referencing, es la opcion mas
 *    lenta pero permite la mayor cantidad de documents
 *
 * Dadas las 3 opciones anteriores, optamos por la primera, dado que es la mas eficiente, y en caso de superar N=1000
 * entonces seria logico subdividir en distintas ordenes de menos de 1000 order_Details
 */

// Resolvemos el ejercicio con el siguiente modelo:

use("shop");
db.createCollection("books", {
  validator: {
    $jsonSchema: {
      bsonType: "object",
      required: ["book_id", "title", "author"],
      properties: {
        book_id: {
          bsonType: "int",
        },
        title: {
          bsonType: "string",
          maxLength: 70,
        },
        author: {
          bsonType: "string",
          maxLength: 70,
        },
        price: {
          bsonType: "decimal",
        },
        category: {
          bsonType: "object",
          required: ["category_id", "category_name"],
          properties: {
            category_id: {
              bsonType: "int",
            },
            category_name: {
              bsonType: "string",
              maxLength: 70,
            },
          },
        },
      },
    },
  },
});

db.createCollection("orders", {
  validator: {
    $jsonSchema: {
      bsonType: "object",
      required: [
        "order_id",
        "delivery_name",
        "delivery_address",
        "cc_name",
        "cc_number",
        "cc_expiry",
      ],
      properties: {
        order_id: {
          bsonType: "long",
        },
        delivery_name: {
          bsonType: "string",
          maxLength: 70,
        },
        delivery_address: {
          bsonType: "string",
          maxLength: 70,
        },
        cc_name: {
          bsonType: "string",
          maxLength: 70,
        },
        cc_number: {
          bsonType: "string",
          maxLength: 32,
        },
        cc_expiry: {
          bsonType: "string",
          maxLength: 20,
        },
        orders: {
          bsonType: "array",
          items: {
            bsonType: "object",
            required: [
              "id",
              "book_id",
              "title",
              "author",
              "quantity",
              "price",
              "order_id",
            ],
            properties: {
              id: {
                bsonType: "long",
              },
              book_id: {
                bsonType: "int",
              },
              title: {
                bsonType: "string",
                maxLength: 70,
              },
              author: {
                bsonType: "string",
                maxLength: 70,
              },
              quantity: {
                bsonType: "int",
              },
              price: {
                bsonType: "decimal",
              },
              order_id: {
                bsonType: "long",
              },
            },
          },
        },
      },
    },
  },
});

// Testeamos el esquema:
// Confio

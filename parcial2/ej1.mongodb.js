use("supplies");

db.sales
  .find({
    storeLocation: {
      $in: ["London", "Austin", "San Diego"],
    },
    "customer.age": {
      $gte: 18,
    },
    items: {
      $elemMatch: {
        price: {
          $gte: NumberDecimal("1000"),
        },
        tags: {
          $in: ["kids", "school"],
        },
      },
    },
  })
  .projection({
    _id: 0,
    sale: "$_id",
    saleDate: 1,
    storeLocation: 1,
    customer_email: "$customer.email",
  });

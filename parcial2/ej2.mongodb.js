use("supplies");

db.sales.aggregate([
  {
    $match: {
      storeLocation: "Seattle",
      purchaseMethod: {
        $in: ["In store", "Phone"],
      },
      saleDate: {
        $gte: ISODate("2014-02-01T00:00:00.000Z"),
        $lte: ISODate("2015-01-31T23:59:59.000Z"),
      },
    },
  },
  {
    $unwind: {
      path: "$items",
    },
  },
  {
    $group: {
      _id: "$_id",
      email: {
        $first: "$customer.email",
      },
      satisfaction: {
        $first: "$customer.satisfaction",
      },
      charged: {
        $sum: {
          $multiply: ["$items.quantity", "$items.price"],
        },
      },
    },
  },
  {
    $project: {
      _id: 0,
      customer_email: "$email",
      customer_satisfaction: "$satisfaction",
      total_amount: "$charged",
    },
  },
  {
    $sort: {
      customer_satisfaction: -1,
      customer_email: 1,
    },
  },
]);

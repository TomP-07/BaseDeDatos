use("supplies");

db.sales.aggregate([
  {
    $addFields: {
      charged: {
        $reduce: {
          input: "$items",
          initialValue: 0,
          in: {
            $sum: [
              "$$value",
              {
                $multiply: ["$$this.price", "$$this.quantity"],
              },
            ],
          },
        },
      },
    },
  },
  {
    $group: {
      _id: "$storeLocation",
      avg_charged: {
        $avg: "$charged",
      },
    },
  },
  {
    $lookup: {
      from: "storeObjectives",
      localField: "_id",
      foreignField: "_id",
      as: "objective",
    },
  },
  {
    $unwind: {
      path: "$objective",
    },
  },
  {
    // Asumimos fuertemente que objective de storeObjectives solo
    // contiene un elemento para cada valor de storeLocation
    $project: {
      _id: 0,
      storeLocation: "$_id",
      venta_promedio: "$avg_charged",
      objetivo: "$objective.objective",
      diferencia: {
        $subtract: ["$avg_charged", "$objective.objective"],
      },
    },
  },
]);

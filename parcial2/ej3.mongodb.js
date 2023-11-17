use("supplies");

const aggregation = [
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
      _id: {
        year: {
          $year: "$saleDate",
        },
        month: {
          $month: "$saleDate",
        },
      },
      min: {
        $min: "$charged",
      },
      max: {
        $max: "$charged",
      },
      avg: {
        $avg: "$charged",
      },
      sum: {
        $sum: "$charged",
      },
    },
  },
  {
    $project: {
      _id: 0,
      year: "$_id.year",
      month: "$_id.month",
      minimo: "$min",
      maximo: "$max",
      promedio: "$avg",
      total: "$sum",
    },
  },
  {
    $sort: {
      year: -1,
      month: -1,
    },
  },
];

db.createView("salesInvoiced", "sales", aggregation);

db.salesInvoiced.find();

use("mflix");
db.theaters.aggregate([
  {
    $group:
      /**
       * _id: The id of the group.
       * fieldN: The first field name.
       */
      {
        _id: "$location.address.state",
        count: {
          $sum: 1,
        },
      },
  },
  {
    $sort:
      /**
       * Provide any number of field/order pairs.
       */
      {
        count: -1,
      },
  },
]);

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
    $match: {
      count: {
        $gte: 2,
      },
    },
  },
  { $count: "total" },
]);

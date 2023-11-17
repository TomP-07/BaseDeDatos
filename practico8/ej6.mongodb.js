use("mflix");

db.comments.aggregate([
  {
    $group:
      /**
       * _id: The id of the group.
       * fieldN: The first field name.
       */
      {
        _id: "$email",
        name: {
          $first: "$name",
        },
        comments: {
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
        comments: -1,
      },
  },
]);

use("mflix");

const aggregation = [
  {
    $sortByCount:
      /**
       * expression: Grouping expression or string.
       */
      "$movie_id",
  },
  {
    $lookup:
      /**
       * from: The target collection.
       * localField: The local join field.
       * foreignField: The target join field.
       * as: The name for the results.
       * pipeline: Optional pipeline to run on the foreign collection.
       * let: Optional variables to use in the pipeline field stages.
       */
      {
        from: "movies",
        localField: "_id",
        foreignField: "_id",
        as: "movie",
      },
  },
  {
    $unwind:
      /**
       * path: Path to the array field.
       * includeArrayIndex: Optional name for index.
       * preserveNullAndEmptyArrays: Optional
       *   toggle to unwind null and empty values.
       */
      {
        path: "$movie",
      },
  },
  {
    $unwind:
      /**
       * path: Path to the array field.
       * includeArrayIndex: Optional name for index.
       * preserveNullAndEmptyArrays: Optional
       *   toggle to unwind null and empty values.
       */
      {
        path: "$movie.genres",
      },
  },
  {
    $group:
      /**
       * _id: The id of the group.
       * fieldN: The first field name.
       */
      {
        _id: "$movie.genres",
        comments: {
          $sum: "$count",
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
  {
    $limit: 5,
  },
];
db.runCommand({
  collMod: "top5genrespercomments",
  viewOn: "comments",
  pipeline: aggregation,
});
// db.createView("top5genrespercomments", "comments", aggregation);
db.top5genrespercomments.find();

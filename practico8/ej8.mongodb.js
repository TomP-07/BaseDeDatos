use("mflix");

db.comments.aggregate([
  {
    $sortByCount:
      /**
       * expression: Grouping expression or string.
       */
      "$movie_id",
  },
  {
    $limit:
      /**
       * Provide the number of documents to limit.
       */
      10,
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
    $project:
      /**
       * specifications: The fields to
       *   include or exclude.
       */
      {
        title: "$movie.title",
        year: "$movie.year",
        comments: "$count",
      },
  },
]);

use("mflix");

db.movies.aggregate([
  {
    $unwind:
      /**
       * path: Path to the array field.
       * includeArrayIndex: Optional name for index.
       * preserveNullAndEmptyArrays: Optional
       *   toggle to unwind null and empty values.
       */
      {
        path: "$genres",
      },
  },
  {
    $sortByCount:
      /**
       * expression: Grouping expression or string.
       */
      "$genres",
  },
  {
    $limit:
      /**
       * Provide the number of documents to limit.
       */
      10,
  },
]);

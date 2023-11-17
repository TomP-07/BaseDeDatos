use("mflix");

const aggregation = [
  {
    $match:
      /**
       * query: The query in MQL.
       */
      {
        directors: {
          $all: ["Jules Bass"],
        },
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
        path: "$cast",
      },
  },
  {
    $group:
      /**
       * _id: The id of the group.
       * fieldN: The first field name.
       */
      {
        _id: "$cast",
        movies_data: {
          $addToSet: {
            title: "$title",
            year: "$year",
          },
        },
      },
  },
  {
    $match:
      /**
       * query: The query in MQL.
       */
      {
        "movies_data.2": {
          $exists: true,
        },
      },
  },
  {
    $project:
      /**
       * specifications: The fields to
       *   include or exclude.
       */
      {
        _id: 0,
        name: "$_id",
        movies: "$movies_data",
      },
  },
];
db.movies.aggregate(aggregation);

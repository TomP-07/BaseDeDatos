use("mflix");

db.movies.aggregate([
  {
    $match: {
      year: {
        $gte: 1980,
        $lte: 1989,
      },
    },
  },
  {
    $group: {
      _id: "$year",
      minimo: {
        $min: "$imdb.rating",
      },
      maximo: {
        $max: "$imdb.rating",
      },
      promedio: {
        $avg: "$imdb.rating",
      },
    },
  },
  {
    $sort: {
      promedio: -1,
    },
  },
  {
    $project: {
      year: "$_id",
      promedio: 1,
      maximo: 1,
      minimo: 1,
      _id: 0,
    },
  },
]);

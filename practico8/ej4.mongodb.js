use("mflix");

db.movies
  .find({
    year: {
      $gte: 1950,
      $lte: 1959,
    },
  })
  .count();

db.movies.aggregate([
  {
    $match: {
      year: {
        $gte: 1950,
        $lte: 1959,
      },
    },
  },
  { $count: "total" },
]);

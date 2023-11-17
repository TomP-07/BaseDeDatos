use("mflix");

db.movies
  .find({
    directors: {
      $all: ["Louis Lumière"],
    },
  })
  .count();

db.movies.aggregate([
  {
    $match: {
      directors: {
        $all: ["Louis Lumière"],
      },
    },
  },
  { $count: "total" },
]);

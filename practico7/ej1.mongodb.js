// 1- Insertar 5 nuevos usuarios en la colección users. Para cada nuevo usuario creado,
//  insertar al menos un comentario realizado por el usuario en la colección comments.
use('mflix')
db.users.insertMany([
    {
        'name': 'name 1',
        'email': 'name_1@example.com',
        'password': 'example123'
    },
    {
        'name': 'name 2',
        'email': 'name_2@example.com',
        'password': 'example123'
    },
    {
        'name': 'name 3',
        'email': 'name_3@example.com',
        'password': 'example123'
    },
    {
        'name': 'name 4',
        'email': 'name_4@example.com',
        'password': 'example123'
    },
    {
        'name': 'name 5',
        'email': 'name_5@example.com',
        'password': 'example123'
    }
]
)

var users = db.users.find({ 'name': /^name/ })

users.forEach(user => {
    db.comments.insertOne(
        {
            "name": user.name,
            "email": user.email,
            "movie_id": new ObjectId("5a9427648b0beebeb69579cc"),
            "text": "Rem officiis eaque repellendus amet eos doloribus. Porro dolor voluptatum voluptates neque culpa molestias. Voluptate unde nulla temporibus ullam.",
            "date": new Date()
        }
    )
});
// TP 9 — MongoDB [P10A, P10B]
// Motor: MongoDB 7.0.43 (contenedor bd2-mongo), cliente mongosh 2.12.
// Registro de las consultas. Las explicaciones están en solucion.md.
// Uso: docker compose exec mongo mongosh lab, y pegar cada bloque.

// =====================================================================
// PARTE I — bandas [P10A, p. 7]
// =====================================================================

// 1) Modelo y carga: una colección, discos embebidos, EFECTO ALFONS como
//    una sola banda con dos fechas de inscripción.
load('/practica/tp-09/bandas.js');

// 2) Todas las bandas, de menor a mayor cantidad de integrantes
db.bandas.find({}, {nombre_solista: 1, integrantes: 1, _id: 0}).sort({integrantes: 1});

// 3) Las dos bandas con más integrantes -> LA SURTIDA FOLCK (7), LMV (6)
db.bandas.find({}, {nombre_solista: 1, integrantes: 1, _id: 0}).sort({integrantes: -1}).limit(2);

// 4) Un integrante más a todas -> matchedCount 11, modifiedCount 11
db.bandas.updateMany({}, {$inc: {integrantes: 1}});

// 5) Género Rock -> EFECTO ALFONS, AFTERLIFE, VIRGINIA FERREYRA
db.bandas.find({genero: 'ROCK'}, {nombre_solista: 1, _id: 0});

// 6) Género Rock o estilo con algo de Rock
//    -> los tres anteriores + TANTAS PREGUNTAS (PUNK ROCK) y TAL VEZ DE PASO (POP ROCK)
//    La regex no está anclada: 'rock' equivale a LIKE '%rock%'; /i ignora mayúsculas.
db.bandas.find({$or: [{genero: 'ROCK'}, {estilo: /rock/i}]}, {nombre_solista: 1, _id: 0});

// 7) Disco en 2006 -> VER K BITCH, TANTAS PREGUNTAS (una vez, aunque tiene dos)
db.bandas.find({'discos.anio': 2006}, {nombre_solista: 1, discos: 1, _id: 0});

// 8) Disco después de 2010 -> TROTAMUNDOS (2014)
db.bandas.find({'discos.anio': {$gt: 2010}}, {nombre_solista: 1, discos: 1, _id: 0});

// 9) Bandas en Barracas -> 2 (con una fila por inscripción serían 3)
db.bandas.countDocuments({barrio: 'BARRACAS'});

// 10) Vista bandas_resumen y promedio de integrantes por género, alfabético
db.bandas_resumen.drop();
db.createView('bandas_resumen', 'bandas', [
  {$project: {_id: 0, nombre_solista: 1, genero: 1, barrio: 1, integrantes: 1}}
]);
db.bandas_resumen.aggregate([
  {$group: {_id: '$genero', promedio_integrantes: {$avg: '$integrantes'}}},
  {$sort: {_id: 1}},
  {$project: {_id: 0, genero: '$_id', promedio_integrantes: 1}}
]);
// FOLKLORE 8, HIP HOP / RAP 2, INDIE 5, INSTRUMENTAL 2, POP 6, PUNK 4, ROCK 4, SOLISTA 2
// (ya incluye el integrante sumado en 4)

// 11) Bandas por barrio, de más a menos; el barrio desempata
db.bandas_resumen.aggregate([
  {$group: {_id: '$barrio', cant_bandas: {$sum: 1}}},
  {$sort: {cant_bandas: -1, _id: 1}}
]);
// BARRACAS 2; los otros nueve barrios 1 cada uno, en orden alfabético

// =====================================================================
// PARTE II [P10B]
// =====================================================================

// --- 4) academica.egresados ------------------------------------------
// a) Desde la terminal del sistema (el CSV está montado en /recursos):
//    docker compose exec mongo mongoimport --db academica --collection egresados \
//      --type csv --headerline --file /recursos/tp-09-egresados.csv
//    -> 8223 documentos. mongoimport infiere tipos: legajo y colacion int,
//       promedios double. El legajo 19115 trae colacion, promedio y
//       promedio_lineal vacíos y quedan como string ''.
use('academica');
db.egresados.aggregate([{$group: {_id: {$type: '$colacion'}, cantidad: {$sum: 1}}}]);
// -> int 8222, string 1
db.egresados.aggregate([{$group: {_id: '$legajo'}}, {$count: 'egresados_distintos'}]);
// -> 8094 personas: 129 títulos son segundas carreras

// b) Egresados (títulos) por carrera -> 19 carreras; Industrial 3847,
//    Electrónico 1099, Químico 635...
db.egresados.aggregate([
  {$group: {_id: '$titulo', egresados: {$sum: 1}}},
  {$sort: {egresados: -1, _id: 1}}
]);

// c) Egresados por colación, de mayor a menor, sin el registro vacío
//    -> 58 colaciones; 57: 342, 51: 309, 48: 306...
db.egresados.aggregate([
  {$match: {colacion: {$type: 'int'}}},
  {$group: {_id: '$colacion', egresados: {$sum: 1}}},
  {$sort: {egresados: -1, _id: 1}}
]);

// c') Variante: personas por colación (COUNT(DISTINCT legajo))
db.egresados.aggregate([
  {$match: {colacion: {$type: 'int'}}},
  {$group: {_id: {legajo: '$legajo', colacion: '$colacion'}}},
  {$group: {_id: '$_id.colacion', personas: {$sum: 1}}},
  {$sort: {personas: -1, _id: 1}}
]);

// --- 1) Libro, día 1: Do.2–Do.5 [B01, pp. 95–98, 109–110] ------------
load('/practica/tp-09/towns.js');   // base book, 3 ciudades
use('book');

// a) Do.2: ciudad con "new", sin distinguir mayúsculas -> New York
db.towns.find({name: /new/i}, {_id: 0, name: 1});

// b) Do.3: nombre con "e" y famosa por comida o cerveza -> New York
//    Portland es famosa por ambas pero no tiene "e"; Punxsutawney tiene "e"
//    pero no es famosa por ninguna.
db.towns.find({name: /e/, famousFor: {$in: ['food', 'beer']}}, {_id: 0, name: 1, famousFor: 1});

// c) Do.4: base blogger, colección articles; el autor como subdocumento
use('blogger');
db.articles.drop();
db.articles.insertOne({
  author: {name: 'Ana Pérez', email: 'ana.perez@example.com'},
  createdAt: new Date('2026-10-13'),
  text: 'Primer artículo del blog.'
});

// d) Do.5: arreglo de comentarios con un comentario (autor y texto)
db.articles.updateOne(
  {'author.email': 'ana.perez@example.com'},
  {$push: {comments: {author: 'Bruno Díaz', text: 'Muy bueno.'}}}
);
db.articles.find({}, {_id: 0});

// --- 2 y 3) Índices y explain: experimento del libro [B01, pp. 110–112] ---
// populatePhones del libro, con insertMany en lote (insert uno a uno tarda).
use('book');
db.phones.drop();
const docs = [];
for (let i = 5550000; i < 5650000; i++) {
  const country = 1 + ((Math.random() * 8) << 0);
  docs.push({_id: country * 1e10 + 800 * 1e7 + i,
             components: {country: country, area: 800, prefix: (i * 1e-4) << 0, number: i},
             display: '+' + country + ' 800-' + i});
}
db.phones.insertMany(docs, {ordered: false});

db.phones.getIndexes();   // 2.b -> solo _id_, creado automáticamente

// El libro busca '+1 800-5650001', que no existe: el rango termina en 5649999.
db.phones.find({display: '+1 800-5650001'}).explain('executionStats');
// -> COLLSCAN, totalDocsExamined 100000, ~120 ms
db.phones.createIndex({display: 1}, {unique: true});   // el libro: ensureIndex + dropDups
db.phones.find({display: '+1 800-5650001'}).explain('executionStats');
// -> FETCH <- IXSCAN display_1, totalDocsExamined 0, ~2 ms

// --- 5) Ciudades, índice 2d y Do.1 del día 3 [B01, pp. 130, 132] -------
// Desde la terminal del sistema:
//   docker compose exec mongo mongoimport --db test --collection cities \
//     --type json --drop --file /recursos/tp-09-mongo-cities.json   -> 99838
use('test');
db.cities.createIndex({location: '2d'});

// Auditoría: el orden de las coordenadas depende del signo.
//   ambos componentes >= 0  -> [lat, lon]   (62678 documentos)
//   algún componente < 0    -> [lon, lat]   (37160 documentos)
//   Ninguna excepción: ningún [lon, lat] tiene |segundo| > 90 y ningún
//   [lat, lon] tiene primero > 90.
db.cities.find({name: {$in: ['London', 'Cambridge', 'Paris', 'Tokyo']},
                country: {$in: ['GB', 'FR', 'JP']}}, {_id: 0, name: 1, location: 1});
// London [-0.12574, 51.50853]  Cambridge [52.2, 0.11667]  Paris [48.85341, 2.3488]

// Do.1 ingenuo sobre los datos tal cual: 297 ciudades, ninguna al este de Greenwich.
const centro = db.cities.findOne({name: 'London', country: 'GB'}).location;
const radio = 50 / 3963.2;   // 50 millas en radianes (radio terrestre 3963.2 mi)
db.cities.countDocuments({location: {$geoWithin: {$centerSphere: [centro, radio]}}});

// Derivado normalizado a [lon, lat], sin tocar el original.
db.cities.aggregate([
  {$set: {location: {$cond: [
    {$and: [{$gte: [{$arrayElemAt: ['$location', 0]}, 0]},
            {$gte: [{$arrayElemAt: ['$location', 1]}, 0]}]},
    [{$arrayElemAt: ['$location', 1]}, {$arrayElemAt: ['$location', 0]}],
    '$location']}}},
  {$out: 'cities_lonlat'}
]);
db.cities_lonlat.createIndex({location: '2d'});

// Do.1: ciudades a 50 millas o menos del centro de Londres -> 453 (156 al este)
db.cities_lonlat.find(
  {location: {$geoWithin: {$centerSphere: [centro, radio]}}},
  {_id: 0, name: 1, population: 1}
).sort({population: -1});
// London, City of London, Islington, Reading, Harrow, Luton, Sutton, Milton Keynes...

// Comparación: $center trata el índice 2d como un plano y el radio en grados
// -> 332: un grado de longitud mide ~69 km a la latitud de Londres, no 111.
db.cities_lonlat.countDocuments({location: {$geoWithin: {$center: [centro, 50 * 1.609344 / 111.32]}}});

// --- 6) SQL -> MongoDB, sobre bandas [P10B, pp. 1–2] -------------------
use('lab');

// a) SELECT nombre_solista FROM bandas WHERE genero = 'ROCK' AND integrantes > 2;
//    -> EFECTO ALFONS, AFTERLIFE (VIRGINIA FERREYRA tiene 2 tras el punto 4)
db.bandas.find({genero: 'ROCK', integrantes: {$gt: 2}}, {_id: 0, nombre_solista: 1});

// b) SELECT genero, AVG(integrantes) AS promedio_integrantes, COUNT(*) AS cant_bandas
//    FROM bandas WHERE fecha_incripcion <= '2017-11-27'
//    GROUP BY genero ORDER BY promedio_integrantes DESC;
db.bandas.aggregate([
  {$match: {fecha_inscripcion: {$lte: new Date('2017-11-27')}}},
  {$group: {_id: '$genero',
            promedio_integrantes: {$avg: '$integrantes'},
            cant_bandas: {$sum: 1}}},
  {$sort: {promedio_integrantes: -1, _id: 1}}
]);
// FOLKLORE 8 (1), POP 6 (2), PUNK 4 (1), ROCK 4 (3), HIP HOP / RAP 2 (1), SOLISTA 2 (1)

// Trampa: comparar la fecha con un string no da error y no devuelve nada.
db.bandas.countDocuments({fecha_inscripcion: {$lte: '2017-11-27'}});   // -> 0

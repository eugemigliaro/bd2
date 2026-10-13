// TP 9, parte II — punto 1: colección towns del libro [B01, pp. 95, 97–98]
// Uso, dentro de mongosh:
//   load('/practica/tp-09/towns.js')
// Adaptado a mongosh: insertOne en lugar de insert. El libro trabaja en la base `book`.

const book = db.getSiblingDB('book');
book.towns.drop();

book.towns.insertOne({
  name: 'New York',
  population: 22200000,
  lastCensus: ISODate('2016-07-01'),
  famousFor: ['the MOMA', 'food', 'Derek Jeter'],
  mayor: {name: 'Bill de Blasio', party: 'D'}
});

// El libro define esta función para cargar las otras dos ciudades.
function insertCity(name, population, lastCensus, famousFor, mayorInfo) {
  book.towns.insertOne({
    name: name,
    population: population,
    lastCensus: ISODate(lastCensus),
    famousFor: famousFor,
    mayor: mayorInfo
  });
}

insertCity('Punxsutawney', 6200, '2016-01-31', ['Punxsutawney Phil'], {name: 'Richard Alexander'});
insertCity('Portland', 582000, '2016-09-20', ['beer', 'food', 'Portlandia'], {name: 'Ted Wheeler', party: 'D'});

print('towns: ' + book.towns.countDocuments({}) + ' documentos');

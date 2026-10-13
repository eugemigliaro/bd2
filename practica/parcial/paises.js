// Ejercicios tipo parcial — colección paises [P14, p. 6]; mismo dominio que T15, pp. 23–27.
// Uso: load('/practica/parcial/paises.js') dentro de mongosh.
const p = db.getSiblingDB('parcial');
p.paises.drop();
p.paises.insertMany([
  {_id: 'us', nombre: 'Estados Unidos', exports: {foods: [{name: 'bacon', tasty: true}, {name: 'burgers'}]}},
  {_id: 'ca', nombre: 'Canadá',         exports: {foods: [{name: 'bacon', tasty: false}, {name: 'syrup', tasty: true}]}},
  {_id: 'mx', nombre: 'México',         exports: {foods: [{name: 'salsa', tasty: true, condiment: true}]}},
  // trampa: exporta bacon sabroso y OTRO alimento no sabroso
  {_id: 'ar', nombre: 'Argentina',      exports: {foods: [{name: 'bacon', tasty: true}, {name: 'mate cocido', tasty: false}]}}
]);
print('paises: ' + p.paises.countDocuments({}));

// Ejercicios tipo parcial — colección productos [P14, pp. 5–6]
// Uso: docker compose exec mongo mongosh parcial, y load('/practica/parcial/productos.js')
// El 101 es el documento del enunciado; los demás cubren casos borde.
const parcial = db.getSiblingDB('parcial');
parcial.productos.drop();
parcial.productos.insertMany([
  {_id: 101, nombre: 'Notebook Lenovo', categoria: 'Informática', precio: 950000, stock: 12,
   marcas: ['Lenovo', 'Intel'], proveedor: {nombre: 'TecnoSur', provincia: 'Buenos Aires'}},
  // marcas en otro orden y con un elemento más; nombre que empieza con "Note"
  {_id: 102, nombre: 'Notebook Gamer', categoria: 'Informática', precio: 1800000, stock: 3,
   marcas: ['Intel', 'Nvidia', 'Lenovo'], proveedor: {nombre: 'Compumundo', provincia: 'Córdoba'}},
  // sin stock; proveedor de Buenos Aires con otro campo más
  {_id: 103, nombre: 'Notebook HP', categoria: 'Informática', precio: 870000, stock: 0,
   marcas: ['HP', 'Intel'], proveedor: {nombre: 'TecnoSur', provincia: 'Buenos Aires', cuit: '30-1'}},
  // minúscula: no empieza con "Note"
  {_id: 104, nombre: 'notepad de papel', categoria: 'Librería', precio: 3000, stock: 100,
   marcas: ['Rivadavia'], proveedor: {nombre: 'Papelera Sur', provincia: 'Buenos Aires'}},
  {_id: 105, nombre: 'Teléfono Galaxy', categoria: 'Telefonía', precio: 1200000, stock: 7,
   marcas: ['Samsung'], proveedor: {nombre: 'CelularYa', provincia: 'Santa Fe'}},
  {_id: 106, nombre: 'iPhone', categoria: 'Telefonía', precio: 2500000, stock: 2,
   marcas: ['Apple', 'Samsung'], proveedor: {nombre: 'CelularYa', provincia: 'Santa Fe'}},
  // sin el atributo marcas
  {_id: 107, nombre: 'Cable USB', categoria: 'Informática', precio: 5000, stock: 0,
   proveedor: {nombre: 'TecnoSur', provincia: 'Buenos Aires'}}
]);
print('productos: ' + parcial.productos.countDocuments({}));

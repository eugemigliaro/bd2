// TP 9, parte I — ejercicio 1: carga de bandas [P10A, p. 7]
// Uso, dentro de mongosh:
//   load('/practica/tp-09/bandas.js')
// Modelo: una colección `bandas`, un documento por banda.
// - discos: arreglo embebido de {titulo, anio}; anio numérico para las consultas 7 y 8.
// - fecha_inscripcion: arreglo de fechas. EFECTO ALFONS aparece en dos filas de la
//   tabla con distinta inscripción y distinto disco; se modela como una sola banda.
// - Campos vacíos en la tabla (estilo, discos) no se guardan.
// - Las fechas se escriben como texto ISO para no caer en los meses 0–11 de new Date(a, m, d).

const lab = db.getSiblingDB('lab');
lab.bandas.drop();

lab.bandas.insertMany([
  {nombre_solista: 'VER K BITCH', genero: 'INSTRUMENTAL',
   fecha_inscripcion: [new Date('2018-01-20')],
   discos: [{titulo: 'DIOS AGUJERO NEGRO', anio: 2008}, {titulo: 'APICHONADOS', anio: 2007},
            {titulo: 'MERIDIANO', anio: 2006}, {titulo: 'CAUSALIDADES', anio: 2005},
            {titulo: 'PLANETA ESMERALDA', anio: 2001}],
   barrio: 'VERSALLES', integrantes: 1},
  {nombre_solista: 'TROTAMUNDOS', genero: 'INDIE',
   fecha_inscripcion: [new Date('2017-11-30')],
   discos: [{titulo: 'HECHO BOLITA', anio: 2014}],
   barrio: 'VILLA LURO', integrantes: 4},
  {nombre_solista: 'EFECTO ALFONS', genero: 'ROCK', estilo: 'POWER TRIO',
   fecha_inscripcion: [new Date('2017-11-06'), new Date('2017-11-27')],
   discos: [{titulo: 'EFECTO ALFONS', anio: 1995}, {titulo: 'EFECTO ALFONS', anio: 2000}],
   barrio: 'BARRACAS', integrantes: 3},
  {nombre_solista: 'MARCELO GIULLITTI', genero: 'SOLISTA',
   fecha_inscripcion: [new Date('2017-11-26')],
   barrio: 'AGRONOMIA', integrantes: 1},
  {nombre_solista: 'AFTERLIFE', genero: 'ROCK', estilo: 'ROCK ALTERNATIVO',
   fecha_inscripcion: [new Date('2017-11-14')],
   barrio: 'BALVANERA', integrantes: 5},
  {nombre_solista: 'VIRGINIA FERREYRA', genero: 'ROCK', estilo: 'ROCK POP',
   fecha_inscripcion: [new Date('2017-11-14')],
   barrio: 'VILLA DEL PARQUE', integrantes: 1},
  {nombre_solista: 'LMV', genero: 'POP',
   fecha_inscripcion: [new Date('2017-11-10')],
   barrio: 'LA LUCILA', integrantes: 6},
  {nombre_solista: 'TANTAS PREGUNTAS', genero: 'PUNK', estilo: 'PUNK ROCK',
   fecha_inscripcion: [new Date('2017-10-27')],
   discos: [{titulo: 'DESPUES DE TODO', anio: 2006}, {titulo: 'LIBRE ALBEDRIO', anio: 2006}],
   barrio: 'MORENO', integrantes: 3},
  {nombre_solista: 'TAL VEZ DE PASO', genero: 'POP', estilo: 'POP ROCK',
   fecha_inscripcion: [new Date('2017-10-26')],
   barrio: 'PUERTO MADERO', integrantes: 4},
  {nombre_solista: 'LA SURTIDA FOLCK', genero: 'FOLKLORE',
   fecha_inscripcion: [new Date('2017-10-25')],
   barrio: 'BERAZATEGUI', integrantes: 7},
  {nombre_solista: 'JAYDEE M', genero: 'HIP HOP / RAP',
   fecha_inscripcion: [new Date('2017-10-24')],
   barrio: 'BARRACAS', integrantes: 1}
]);

print('bandas: ' + lab.bandas.countDocuments({}) + ' documentos');

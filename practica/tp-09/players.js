// TP 9, parte I — paso 10: los 12 jugadores de la guía [P10A, pp. 2–3]
// Uso, dentro de mongosh con la base lab seleccionada:
//   load('/practica/tp-09/players.js')
// Se corrigieron los espacios múltiples que deja la justificación del PDF.
// 'Watching TVseries' (Neymar) está así en el original y se conserva.
// Los meses de new Date() van de 0 a 11: new Date(1985,9,9) es el 9 de octubre.

db.players.insertOne({name:'Luka Modric', height: 180, weight:143, dob: new Date(1985,9,9,0,0), preferred_foot: 'right', hobbies:['Playing football','Watching TV series','Swimming']});
db.players.insertOne({name:'Harry Kane', weight:143, dob: new Date(1993,7,28,0,0), preferred_foot: 'right', hobbies:['Watching Movies','Swimming']});
db.players.insertOne({name:'Neymar', height: 175, weight:150, dob: new Date(1992,2,5,0,0), preferred_foot: 'right', hobbies:['Video games','Watching TVseries','Swimming']});
db.players.insertOne({name:'David Silva', height: 170, weight:148, dob: new Date(1986,8,1,0,0), preferred_foot: 'left', hobbies:['Playing football', 'Watching Movies']});
db.players.insertOne({name:'Eden Hazard', height: 172, weight:163, dob: new Date(1991,1,7,0,0), preferred_foot: 'right', hobbies:['Watching Movies','Video games','Watching TV series']});
db.players.insertOne({name:'Antoine Griezmann', height: 175, weight:148, dob: new Date(1991,3,21,0,0), preferred_foot: 'left', hobbies:['Video games','Swimming']});
db.players.insertOne({name:'Lionel Messi', height: 170, weight:159, dob: new Date(1987,6,24,0,0), preferred_foot: 'left', hobbies:['Watching Movies','Video games','Watching TV series','Swimming']});
db.players.insertOne({name:'Cristiano Ronaldo', height: 185, weight:176, dob: new Date(1985,2,5,0,0), preferred_foot: 'left', hobbies:['Video games','Swimming']});
db.players.insertOne({name:'Toni Kroos', height: 182, weight:172, dob: new Date(1990,1,4,0,0), preferred_foot: 'right', hobbies:['Watching Movies','Video games','Watching TV series']});
db.players.insertOne({name:'Sergio Ramos', height: 182, weight:165, dob: new Date(1986,3,30,0,0), preferred_foot: 'right', hobbies:['Video games','Watching TV series']});
db.players.insertOne({name:'Samuel Umtiti', height: 180, weight:165, dob: new Date(1993,11,14,0,0), preferred_foot: 'left', hobbies:['Playing football','Swimming']});
db.players.insertOne({name:'Paulo Dybala', height: 175, weight:161, dob: new Date(1993,11,15,0,0), preferred_foot: 'left', hobbies:['Playing football','Watching TV series','Swimming']});

print('players: ' + db.players.countDocuments({}) + ' documentos');

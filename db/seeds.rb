
puts "== Limpiando base de datos =="
Favorite.destroy_all
Song.destroy_all
Artist.destroy_all
Genre.destroy_all
User.destroy_all

puts "== Creando Usuarios =="
admin = User.create!(username: "admin", email: "admin@prmusic.com", role: "admin")
user1 = User.create!(username: "elmejor512", email: "elmejor512@prmusic.com", role: "user")
user2 = User.create!(username: "luisperez576", email: "luis@prmusic.com", role: "user")
user3 = User.create!(username: "carlosalberto12", email: "carlos@prmusic.com", role: "user")
user4 = User.create!(username: "bauti", email: "bauti@prmusic.com", role: "user")

puts "== Creando Géneros =="
rock_nacional = Genre.create!(name: "Rock Nacional")
heavy_metal = Genre.create!(name: "Heavy Metal")
rock = Genre.create!(name: "Rock")
folklore = Genre.create!(name: "Folklore")

puts "== Creando Artistas =="
hermetica = Artist.create!(name: "Hermética", bio: "Banda argentina de thrash metal y heavy metal fundada en 1988 por Ricardo Iorio.")
redondos = Artist.create!(name: "Patricio Rey y sus Redonditos de Ricota", bio: "Legendaria banda de rock argentina formada en La Plata, liderada por el Indio Solari y Skay Beilinson.")
gardelitos = Artist.create!(name: "Los Gardelitos", bio: "Banda de rock de Bajo Flores fundada por Korneta Suárez en 1995.")
almendra = Artist.create!(name: "Almendra", bio: "Banda pionera del rock argentino liderada por Luis Alberto Spinetta.")
soda = Artist.create!(name: "Soda Stereo", bio: "Mítica banda de rock en español liderada por Gustavo Cerati.")

puts "== Creando Canciones=="
muchacha = Song.create!(
  title: "Muchacha ojos de papel",
  artist: almendra,
  genre: rock_nacional,
  user: user4,
  original_key: "G",
  content: <<~CONTENT
    [INTRO] G - D - Em - C

    G           D
    Muchacha ojos de papel
    Em          C
    ¿Adónde vas? Quédate hasta el alba
    G           D
    Muchacha pequeños pies
    Em          C
    No corras más, quédate hasta el alba

    Am             D
    Sueña un sueño despacito entre mis manos
    G              Em
    Hasta que todo el pueblo cante
    C          D                 G
    Si al despertar el diáfano cielo llora
    Em         C            D
    Es porque vos no estás aquí

    G           D
    Muchacha pechos de miel
    Em          C
    No corras más, quédate hasta el alba
  CONTENT
)

Song.create!(
  title: "Ayer deseo, hoy realidad",
  artist: hermetica,
  genre: heavy_metal,
  user: user1,
  original_key: "Em",
  content: <<~CONTENT
    [INTRO] Em - G - D - C

    Em             G
    Ayer deseo, hoy realidad
    D              C
    De pie sobre el camino
    Em             G
    Buscando la claridad
    D              C
    Que guiará mi destino

    G              D
    Cansado de promesas ya
    C              Em
    De falsos gobernantes
    G              D
    Mi voz no callará jamás
    C              D      Em
    Soy el grito constante
  CONTENT
)

Song.create!(
  title: "Rock para los dientes",
  artist: redondos,
  genre: rock_nacional,
  user: user2,
  original_key: "A",
  content: <<~CONTENT
    [INTRO] A - D - A - E

    A
    Manzanas en la nieve
    D
    Cintas de gasa gris
    A
    La noche se hace humo
    E               A
    Y empieza a sonreír

    D
    Un rock para los dientes
    A
    Mordiendo la ilusión
    E
    Perdidos en el centro
    D           A
    Del viejo callejón
  CONTENT
)

Song.create!(
  title: "Gardeliando",
  artist: gardelitos,
  genre: rock,
  user: user3,
  original_key: "D",
  content: <<~CONTENT
    [INTRO] D - G - A - D

    D              G
    Gardeliando por la esquina
    A              D
    Del barrio que me vio nacer
    D              G
    Con la guitarra en la mano
    A              D
    Y una birra para beber

    G              A
    Y aunque la noche esté fría
    D              Bm
    El fuego sigue encendido
    G              A
    Canto por los compañeros
    G          A     D
    Que nunca se han rendido
  CONTENT
)

puts "== Creando Favoritos =="
Favorite.create!(user: user4, song: muchacha)

puts "== Semillas cargadas exitosamente =="
puts "Total Usuarios: #{User.count}"
puts "Total Artistas: #{Artist.count}"
puts "Total Géneros: #{Genre.count}"
puts "Total Canciones: #{Song.count}"
puts "Total Favoritos: #{Favorite.count}"

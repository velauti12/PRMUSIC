require "test_helper"

class Api::V1::ProposedArtistsTest < ActionDispatch::IntegrationTest
  def post_song(artist_fields)
    post "/api/v1/songs", headers: auth_headers(users(:one)), as: :json, params: {
      song: { title: "Tema nuevo", genre_id: genres(:one).id, original_key: "G", content: "G  D\nLetra de prueba" }.merge(artist_fields)
    }
  end

  test "subir una canción con un artista que no existe lo crea pendiente" do
    assert_difference "Artist.count", 1 do
      post_song(artist_name: "Los Redondos")
    end
    assert_response :created
    artist = Artist.find_by(name: "Los Redondos")
    assert artist.pending?
    assert_equal users(:one), artist.user
    assert_equal artist.id, json["artist"]["id"]
  end

  test "si el artista ya existe con otras mayúsculas se reutiliza" do
    assert_no_difference "Artist.count" do
      post_song(artist_name: "  almendra ")
    end
    assert_equal artists(:one).id, json["artist"]["id"]
  end

  test "si la canción no es válida no queda el artista creado" do
    assert_no_difference [ "Artist.count", "Song.count" ] do
      post "/api/v1/songs", headers: auth_headers(users(:one)), as: :json,
        params: { song: { title: "", artist_name: "Banda Fantasma", genre_id: genres(:one).id, original_key: "G", content: "corto" } }
    end
    assert_response :unprocessable_entity
  end

  test "los artistas pendientes no aparecen en el sitio" do
    pending = Artist.create!(name: "Pendiente SA", status: :pending, user: users(:one))
    get "/api/v1/artists"
    assert_not_includes json.map { |a| a["id"] }, pending.id

    get "/api/v1/artists/#{pending.id}"
    assert_response :not_found
  end
end

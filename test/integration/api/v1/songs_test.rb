require "test_helper"

class Api::V1::SongsTest < ActionDispatch::IntegrationTest
  test "index lista solo canciones aprobadas con artista y género" do
    get "/api/v1/songs"
    assert_response :ok
    titles = json.map { |s| s["title"] }
    assert_includes titles, songs(:one).title
    assert_not_includes titles, songs(:two).title
    assert_equal "Almendra", json.first["artist"]["name"]
  end

  test "index filtra por texto con q" do
    get "/api/v1/songs", params: { q: "muchacha" }
    assert_equal 1, json.size
    get "/api/v1/songs", params: { q: "no existe" }
    assert_equal [], json
  end

  test "show de una canción pendiente es 404 para anónimos y visible para su autor" do
    get "/api/v1/songs/#{songs(:two).id}"
    assert_response :not_found

    get "/api/v1/songs/#{songs(:two).id}", headers: auth_headers(users(:two))
    assert_response :ok
  end

  test "show de un id inexistente responde 404 en JSON" do
    get "/api/v1/songs/999999"
    assert_response :not_found
    assert_equal "Recurso no encontrado", json["error"]
  end

  test "create sin token responde 401" do
    post "/api/v1/songs", params: { song: { title: "Nueva" } }, as: :json
    assert_response :unauthorized
  end

  test "create asigna el autor desde el token y queda pendiente" do
    user = users(:one)
    assert_difference "Song.count", 1 do
      post "/api/v1/songs", headers: auth_headers(user), as: :json, params: {
        song: { title: "Tema nuevo", artist_id: artists(:one).id, genre_id: genres(:one).id,
                original_key: "G", content: "G  D\nLetra de prueba", user_id: users(:two).id }
      }
    end
    assert_response :created
    song = Song.last
    assert_equal user, song.user
    assert song.pending?
  end

  test "create con datos inválidos responde 422 con errores" do
    post "/api/v1/songs", headers: auth_headers(users(:one)), as: :json,
      params: { song: { title: "", artist_id: artists(:one).id, original_key: "XYZ", content: "corto" } }
    assert_response :unprocessable_entity
    assert json["errors"].any?
  end

  test "mine devuelve las canciones del usuario en cualquier estado" do
    get "/api/v1/songs/mine", headers: auth_headers(users(:two))
    assert_response :ok
    assert_equal [ songs(:two).id ], json.map { |s| s["id"] }
    assert_equal "pending", json.first["status"]
  end

  test "transpose devuelve acordes y tonalidad transpuestos" do
    get "/api/v1/songs/#{songs(:one).id}/transpose", params: { semitones: -2 }
    assert_response :ok
    assert_equal "Gm", json["key"]
    assert_match(/^Gm\s+F$/, json["content"].lines.first.strip)
    assert_includes json["content"], "Muchacha ojos de papel"
  end

  test "update y destroy requieren admin" do
    patch "/api/v1/songs/#{songs(:one).id}", headers: auth_headers(users(:one)), as: :json,
      params: { song: { title: "Cambio" } }
    assert_response :forbidden

    delete "/api/v1/songs/#{songs(:one).id}", headers: auth_headers(users(:admin))
    assert_response :no_content
  end

  test "la canción devuelve el id del video de YouTube" do
    songs(:one).update!(video_url: "https://youtu.be/dQw4w9WgXcQ")
    get "/api/v1/songs/#{songs(:one).id}"
    assert_equal "dQw4w9WgXcQ", json["youtube_id"]
  end
end

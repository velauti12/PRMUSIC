require "test_helper"

class AdminSongsTest < ActionDispatch::IntegrationTest
  setup do
    @auth = { "Authorization" => ActionController::HttpAuthentication::Basic.encode_credentials("admin", "admin") }
  end

  test "el inicio muestra las canciones para revisar" do
    get "/admin", headers: @auth
    assert_response :ok
    assert_includes response.body, songs(:two).title
  end

  test "aprobar una canción la publica" do
    patch "/admin/songs/#{songs(:two).id}/approve", headers: @auth
    assert songs(:two).reload.approved?
    follow_redirect! headers: @auth
    assert_includes response.body, "aprobada"
  end

  test "rechazar una canción" do
    patch "/admin/songs/#{songs(:two).id}/reject", headers: @auth
    assert songs(:two).reload.rejected?
  end

  test "el listado filtra por estado" do
    get "/admin/songs", params: { status: "pending" }, headers: @auth
    assert_response :ok
    assert_includes response.body, songs(:two).title
    assert_not_includes response.body, songs(:one).title
  end

  test "la cifra se puede ver transpuesta" do
    get "/admin/songs/#{songs(:one).id}", params: { tono: 2 }, headers: @auth
    assert_response :ok
    assert_includes response.body, "Bm"
    assert_includes response.body, "Muchacha ojos de papel"
  end

  test "una canción creada desde el admin queda a nombre de un admin" do
    post "/admin/songs", headers: @auth, params: {
      song: { title: "Nueva", artist_id: artists(:one).id, genre_id: genres(:one).id, original_key: "G", content: "G  D\nLetra de prueba", status: "approved" }
    }
    song = Song.order(:created_at).last
    assert_equal users(:admin), song.user
    assert song.approved?
  end

  test "la ficha de un usuario muestra sus aportes" do
    get "/admin/users/#{users(:two).id}", headers: @auth
    assert_response :ok
    assert_includes response.body, songs(:two).title
  end

  test "no deja borrar un género que tiene canciones" do
    assert_no_difference "Genre.count" do
      delete "/admin/genres/#{genres(:one).id}", headers: @auth
    end
    follow_redirect! headers: @auth
    assert_includes response.body, "todavía tiene canciones"
  end
end

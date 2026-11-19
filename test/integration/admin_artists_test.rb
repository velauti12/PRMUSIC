require "test_helper"

class AdminArtistsTest < ActionDispatch::IntegrationTest
  setup do
    @auth = { "Authorization" => ActionController::HttpAuthentication::Basic.encode_credentials("admin", "admin") }
    @proposed = Artist.create!(name: "Soda Estereo", status: :pending, user: users(:two))
    @song = songs(:two)
    @song.update!(artist: @proposed)
  end

  test "aprobar la canción aprueba también al artista nuevo" do
    patch "/admin/songs/#{@song.id}/approve", headers: @auth
    assert @song.reload.approved?
    assert @proposed.reload.approved?
  end

  test "aprobar un artista" do
    patch "/admin/artists/#{@proposed.id}/approve", headers: @auth
    assert @proposed.reload.approved?
  end

  test "unir un artista propuesto con uno existente" do
    patch "/admin/artists/#{@proposed.id}/merge", headers: @auth, params: { target_id: artists(:two).id }
    assert_not Artist.exists?(@proposed.id)
    assert_equal artists(:two), @song.reload.artist
  end

  test "la lista muestra quién lo propuso" do
    get "/admin/artists", headers: @auth
    assert_response :ok
    assert_includes response.body, "propuesto por #{users(:two).username}"
  end
end

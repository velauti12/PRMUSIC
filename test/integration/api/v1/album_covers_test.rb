require "test_helper"

class Api::V1::AlbumCoversTest < ActionDispatch::IntegrationTest
  test "el detalle incluye el álbum con la URL de la portada" do
    albums(:one).cover.attach(io: file_fixture("cover.png").open, filename: "cover.png", content_type: "image/png")

    get "/api/v1/songs/#{songs(:one).id}"
    assert_response :ok
    album = json["album"]
    assert_equal albums(:one).title, album["title"]
    assert_match %r{/rails/active_storage/blobs/.+/cover\.png\z}, album["cover_url"]

    # La URL devuelta sirve la imagen (redirige al archivo)
    get URI(album["cover_url"]).path
    assert_response :redirect
  end

  test "sin portada, cover_url es null" do
    get "/api/v1/songs"
    song = json.find { |s| s["id"] == songs(:one).id }
    assert_equal albums(:one).id, song["album"]["id"]
    assert_nil song["album"]["cover_url"]
  end

  test "una canción sin álbum devuelve album null" do
    get "/api/v1/songs/mine", headers: auth_headers(users(:two))
    assert_nil json.first["album"]
  end
end

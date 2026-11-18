require "test_helper"

class AdminAlbumsTest < ActionDispatch::IntegrationTest
  include ActiveJob::TestHelper

  setup do
    @auth = { "Authorization" => ActionController::HttpAuthentication::Basic.encode_credentials("admin", "admin") }
  end

  test "sin credenciales no entra al back-office" do
    get "/admin/albums"
    assert_response :unauthorized
  end

  test "lista los álbumes" do
    get "/admin/albums", headers: @auth
    assert_response :ok
    assert_includes response.body, albums(:one).title
  end

  test "crea un álbum con portada" do
    assert_difference "Album.count", 1 do
      post "/admin/albums", headers: @auth, params: {
        album: { title: "Muchacha", artist_id: artists(:one).id,
                 cover: fixture_file_upload("cover.png", "image/png") }
      }
    end
    assert_redirected_to "/admin/albums"
    assert Album.order(:created_at).last.cover.attached?
  end

  test "no guarda una portada que no es imagen" do
    assert_no_difference "Album.count" do
      post "/admin/albums", headers: @auth, params: {
        album: { title: "Malo", artist_id: artists(:one).id,
                 cover: fixture_file_upload("not_an_image.txt", "text/plain") }
      }
    end
    assert_response :unprocessable_entity
  end

  test "editar muestra la portada actual y permite quitarla" do
    album = albums(:one)
    album.cover.attach(io: file_fixture("cover.png").open, filename: "cover.png", content_type: "image/png")

    get "/admin/albums/#{album.id}/edit", headers: @auth
    assert_response :ok
    assert_includes response.body, "Quitar portada actual"

    patch "/admin/albums/#{album.id}", headers: @auth, params: { album: { title: album.title, remove_cover: "1" } }
    assert_redirected_to "/admin/albums"
    perform_enqueued_jobs
    assert_not album.reload.cover.attached?
  end
end

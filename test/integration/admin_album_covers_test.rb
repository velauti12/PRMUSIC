require "test_helper"

class AdminAlbumCoversTest < ActionDispatch::IntegrationTest
  FakeResponse = Struct.new(:body)
  IMAGE_URL = "https://cdn-images.dzcdn.net/images/cover/abc/1000x1000.jpg".freeze

  setup do
    @auth = { "Authorization" => ActionController::HttpAuthentication::Basic.encode_credentials("admin", "admin") }
  end

  # Reemplaza la llamada a Deezer por respuestas armadas a mano
  def with_fake_deezer
    search = { data: [ { title: "Oktubre", artist: { name: "Almendra" }, cover_xl: IMAGE_URL, cover_medium: IMAGE_URL } ] }.to_json
    image = file_fixture("cover.png").binread
    original = CoverFinder.method(:get)
    CoverFinder.define_singleton_method(:get) { |uri| FakeResponse.new(uri.host == "api.deezer.com" ? search : image) }
    yield
  ensure
    CoverFinder.define_singleton_method(:get, original)
  end

  test "busca tapas con el título y el artista del formulario" do
    with_fake_deezer do
      get "/admin/albums/cover_search", params: { title: "Oktubre", artist_id: artists(:one).id }, headers: @auth
    end
    assert_response :ok
    assert_equal IMAGE_URL, JSON.parse(response.body).first["image_url"]
  end

  test "sin título o artista avisa qué falta" do
    get "/admin/albums/cover_search", params: { title: "" }, headers: @auth
    assert_response :unprocessable_entity
    assert_match "Completá el título", JSON.parse(response.body)["error"]
  end

  test "crear un álbum con la tapa elegida la guarda" do
    with_fake_deezer do
      post "/admin/albums", headers: @auth,
        params: { album: { title: "Oktubre", artist_id: artists(:one).id, cover_url: IMAGE_URL } }
    end
    assert_redirected_to "/admin/albums"
    assert Album.find_by(title: "Oktubre").cover.attached?
  end

  test "no descarga imágenes que no sean de Deezer" do
    assert_no_difference "Album.count" do
      post "/admin/albums", headers: @auth,
        params: { album: { title: "Trucho", artist_id: artists(:one).id, cover_url: "https://example.com/x.jpg" } }
    end
    assert_response :unprocessable_entity
    assert_includes response.body, "La imagen no es de Deezer"
  end

  test "si Deezer no responde lo avisa" do
    original = CoverFinder.method(:get)
    CoverFinder.define_singleton_method(:get) { |_uri| raise CoverFinder::Error, "No se pudo conectar con Deezer." }
    get "/admin/albums/cover_search", params: { title: "Oktubre", artist_id: artists(:one).id }, headers: @auth
    assert_response :bad_gateway
    assert_match "No se pudo conectar", JSON.parse(response.body)["error"]
  ensure
    CoverFinder.define_singleton_method(:get, original)
  end
end

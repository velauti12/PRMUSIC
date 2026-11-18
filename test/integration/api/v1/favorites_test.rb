require "test_helper"

class Api::V1::FavoritesTest < ActionDispatch::IntegrationTest
  test "index requiere token" do
    get "/api/v1/favorites"
    assert_response :unauthorized
  end

  test "index devuelve solo los favoritos propios con la canción" do
    get "/api/v1/favorites", headers: auth_headers(users(:one))
    assert_response :ok
    assert_equal [ favorites(:one).id ], json.map { |f| f["id"] }
    assert_equal songs(:one).title, json.first["song"]["title"]

    get "/api/v1/favorites", headers: auth_headers(users(:two))
    assert_equal [], json
  end

  test "create agrega un favorito para el usuario del token" do
    assert_difference "users(:two).favorites.count", 1 do
      post "/api/v1/favorites", headers: auth_headers(users(:two)), as: :json,
        params: { favorite: { song_id: songs(:one).id } }
    end
    assert_response :created
  end

  test "create duplicado responde 422" do
    post "/api/v1/favorites", headers: auth_headers(users(:one)), as: :json,
      params: { favorite: { song_id: songs(:one).id } }
    assert_response :unprocessable_entity
  end

  test "destroy borra un favorito propio" do
    delete "/api/v1/favorites/#{favorites(:one).id}", headers: auth_headers(users(:one))
    assert_response :no_content
  end

  test "destroy de un favorito ajeno responde 404" do
    delete "/api/v1/favorites/#{favorites(:one).id}", headers: auth_headers(users(:two))
    assert_response :not_found
    assert Favorite.exists?(favorites(:one).id)
  end
end

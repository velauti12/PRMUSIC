require "test_helper"

class Api::V1::CatalogTest < ActionDispatch::IntegrationTest
  test "detalle de artista incluye solo canciones aprobadas" do
    get "/api/v1/artists/#{artists(:two).id}"
    assert_response :ok
    assert_equal "Hermética", json["name"]
    assert_equal [], json["songs"]
  end

  test "detalle de género lista sus canciones aprobadas" do
    get "/api/v1/genres/#{genres(:one).id}"
    assert_response :ok
    assert_equal [ songs(:one).id ], json["songs"].map { |s| s["id"] }
  end

  test "las respuestas de usuarios no exponen token ni contraseña" do
    get "/api/v1/users/#{users(:one).id}"
    assert_response :ok
    assert_nil json["token"]
    assert_nil json["password_digest"]
    assert_nil json["email"]
  end

  test "listado de usuarios requiere admin" do
    get "/api/v1/users"
    assert_response :unauthorized
    get "/api/v1/users", headers: auth_headers(users(:admin))
    assert_response :ok
    assert json.none? { |u| u.key?("token") || u.key?("password_digest") }
  end
end

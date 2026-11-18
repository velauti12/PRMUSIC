require "test_helper"

class Api::V1::SessionsTest < ActionDispatch::IntegrationTest
  test "login exitoso devuelve token, id, username y rol" do
    post "/api/v1/login", params: { username: "usuario_uno", password: "password123" }, as: :json
    assert_response :ok
    assert json["token"].present?
    assert_equal users(:one).id, json["user_id"]
    assert_equal "usuario_uno", json["username"]
    assert_equal "user", json["role"]
  end

  test "login con contraseña incorrecta responde 401" do
    post "/api/v1/login", params: { username: "usuario_uno", password: "mala" }, as: :json
    assert_response :unauthorized
    assert_equal "Credenciales inválidas", json["error"]
  end

  test "logout invalida el token" do
    user = users(:one)
    delete "/api/v1/logout", headers: auth_headers(user)
    assert_response :no_content

    get "/api/v1/favorites", headers: { "Authorization" => "Bearer token-usuario-uno" }
    assert_response :unauthorized
  end
end

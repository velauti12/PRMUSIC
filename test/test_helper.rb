ENV["RAILS_ENV"] ||= "test"
require_relative "../config/environment"
require "rails/test_help"

module ActiveSupport
  class TestCase
    # Run tests in parallel with specified workers
    # En Windows no existe fork, así que ahí los tests corren en un solo proceso
    parallelize(workers: Gem.win_platform? ? 1 : :number_of_processors)

    # Setup all fixtures in test/fixtures/*.yml for all tests in alphabetical order.
    fixtures :all

    # Add more helper methods to be used by all tests here...
  end
end

module ApiTestHelpers
  def auth_headers(user)
    { "Authorization" => "Bearer #{user.token}" }
  end

  def json
    JSON.parse(response.body)
  end
end

class ActionDispatch::IntegrationTest
  include ApiTestHelpers
end

module Admin
  class BaseController < ApplicationController
    layout "admin"

    http_basic_authenticate_with name: ENV.fetch("ADMIN_USERNAME", "admin"), 
                                 password: ENV.fetch("ADMIN_PASSWORD", "admin")
  end
end

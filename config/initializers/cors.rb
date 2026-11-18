# Permite que el frontend (SPA en otro origen) consuma la API.
# En desarrollo el front corre en Vite (localhost:5173). En producción se
# configura con la variable de entorno FRONTEND_URL (se aceptan varias separadas por coma).
Rails.application.config.middleware.insert_before 0, Rack::Cors do
  allow do
    origins(*ENV.fetch("FRONTEND_URL", "http://localhost:5173,http://127.0.0.1:5173").split(",").map(&:strip))

    resource "/api/*",
      headers: :any,
      methods: %i[get post put patch delete options head]
  end
end

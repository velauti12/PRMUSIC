module Api
  module V1
    # Controlador base de la API: todas las respuestas (incluidos los errores) son JSON.
    class BaseController < ApplicationController
      rescue_from ActiveRecord::RecordNotFound do
        render json: { error: "Recurso no encontrado" }, status: :not_found
      end

      rescue_from ActionController::ParameterMissing do |e|
        render json: { error: "Falta el parámetro requerido: #{e.param}" }, status: :bad_request
      end

      private

      SONG_INCLUDES = {
        artist: { only: %i[id name] },
        genre: { only: %i[id name] }
      }.freeze

      # Asociaciones a precargar para serializar canciones sin consultas N+1
      SONG_PRELOAD = [ :artist, :genre, { album: { cover_attachment: :blob } } ].freeze

      # Canción con artista, género y álbum (con la URL pública de la portada, si tiene)
      def song_json(song)
        song.as_json(include: SONG_INCLUDES).merge("album" => album_json(song.album))
      end

      def album_json(album)
        return nil unless album

        {
          "id" => album.id,
          "title" => album.title,
          "cover_url" => album.cover.attached? ? url_for(album.cover) : nil
        }
      end
    end
  end
end

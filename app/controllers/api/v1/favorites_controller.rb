module Api
  module V1
    # Favoritos del usuario logueado. Cada usuario solo ve y modifica los suyos.
    class FavoritesController < BaseController
      before_action :authenticate_token!
      before_action :set_favorite, only: %i[show destroy]

      # GET /api/v1/favorites
      def index
        favorites = @current_user.favorites.includes(song: %i[artist genre]).order(created_at: :desc)
        render json: favorites, include: FAVORITE_INCLUDES
      end

      def show
        render json: @favorite, include: FAVORITE_INCLUDES
      end

      # POST /api/v1/favorites  { "favorite": { "song_id": 2 } }
      def create
        song = Song.approved.find(favorite_params[:song_id])
        favorite = @current_user.favorites.new(song: song)
        if favorite.save
          render json: favorite, include: FAVORITE_INCLUDES, status: :created
        else
          render json: { errors: favorite.errors.full_messages }, status: :unprocessable_entity
        end
      end

      def destroy
        @favorite.destroy
        head :no_content
      end

      private

      FAVORITE_INCLUDES = {
        song: {
          only: %i[id title original_key],
          include: { artist: { only: %i[id name] }, genre: { only: %i[id name] } }
        }
      }.freeze

      # Busca solo dentro de los favoritos propios: si es de otro usuario, responde 404.
      def set_favorite
        @favorite = @current_user.favorites.find(params[:id])
      end

      def favorite_params
        params.require(:favorite).permit(:song_id)
      end
    end
  end
end

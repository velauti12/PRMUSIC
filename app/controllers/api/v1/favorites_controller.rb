module Api
  module V1
    class FavoritesController < ApplicationController
      before_action :authenticate_admin_token!, except: %i[index show create]
      before_action :set_favorite, only: %i[show update destroy]

      def index
        render json: Favorite.all
      end

      def show
        render json: @favorite
      end

      def create
        favorite = Favorite.new(favorite_params)
        if favorite.save
          render json: favorite, status: :created
        else
          render json: { errors: favorite.errors.full_messages }, status: :unprocessable_entity
        end
      end

      def update
        if @favorite.update(favorite_params)
          render json: @favorite
        else
          render json: { errors: @favorite.errors.full_messages }, status: :unprocessable_entity
        end
      end

      def destroy
        @favorite.destroy
        head :no_content
      end

      private

      def set_favorite
        @favorite = Favorite.find(params[:id])
      end

      def favorite_params
        params.require(:favorite).permit(:user_id, :song_id)
      end
    end
  end
end

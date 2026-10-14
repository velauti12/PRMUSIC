module Api
  module V1
    class ArtistsController < ApplicationController
      before_action :authenticate_admin_token!, except: %i[index show]
      before_action :set_artist, only: %i[show update destroy]

      def index
        render json: Artist.all
      end

      def show
        render json: @artist, include: :songs
      end

      def create
        artist = Artist.new(artist_params)
        if artist.save
          render json: artist, status: :created
        else
          render json: { errors: artist.errors.full_messages }, status: :unprocessable_entity
        end
      end

      def update
        if @artist.update(artist_params)
          render json: @artist
        else
          render json: { errors: @artist.errors.full_messages }, status: :unprocessable_entity
        end
      end

      def destroy
        @artist.destroy
        head :no_content
      end

      private

      def set_artist
        @artist = Artist.find(params[:id])
      end

      def artist_params
        params.require(:artist).permit(:name, :bio)
      end
    end
  end
end

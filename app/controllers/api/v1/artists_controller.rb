module Api
  module V1
    class ArtistsController < BaseController
      before_action :authenticate_admin_token!, except: %i[index show]
      before_action :set_artist, only: %i[update destroy]

      def index
        render json: Artist.approved.order(:name).as_json(only: %i[id name bio])
      end

      def show
        @artist = Artist.approved.find(params[:id])
        # Solo se listan las canciones aprobadas
        songs = @artist.songs.approved.includes(:artist, :genre).order(:title)
        render json: @artist.as_json(only: %i[id name bio]).merge(
          songs: songs.as_json(include: { artist: { only: %i[id name] }, genre: { only: %i[id name] } })
        )
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

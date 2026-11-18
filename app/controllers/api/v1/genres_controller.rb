module Api
  module V1
    class GenresController < BaseController
      before_action :authenticate_admin_token!, except: %i[index show]
      before_action :set_genre, only: %i[show update destroy]

      def index
        render json: Genre.order(:name)
      end

      def show
        # Solo se listan las canciones aprobadas
        songs = @genre.songs.approved.includes(:artist, :genre).order(:title)
        render json: @genre.as_json.merge(
          songs: songs.as_json(include: { artist: { only: %i[id name] }, genre: { only: %i[id name] } })
        )
      end

      def create
        genre = Genre.new(genre_params)
        if genre.save
          render json: genre, status: :created
        else
          render json: { errors: genre.errors.full_messages }, status: :unprocessable_entity
        end
      end

      def update
        if @genre.update(genre_params)
          render json: @genre
        else
          render json: { errors: @genre.errors.full_messages }, status: :unprocessable_entity
        end
      end

      def destroy
        @genre.destroy
        head :no_content
      end

      private

      def set_genre
        @genre = Genre.find(params[:id])
      end

      def genre_params
        params.require(:genre).permit(:name)
      end
    end
  end
end

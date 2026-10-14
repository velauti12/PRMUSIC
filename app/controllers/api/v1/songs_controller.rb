module Api
  module V1
    class SongsController < ApplicationController
      before_action :authenticate_admin_token!, except: %i[index show create]
      before_action :set_song, only: %i[show update destroy]

      def index
        render json: Song.approved.includes(:artist, :genre).all, include: [ :artist, :genre ]
      end

      def show
        render json: @song, include: [ :artist, :genre ]
      end

      def create
        song = Song.new(song_params)
        if song.save
          render json: song, status: :created
        else
          render json: { errors: song.errors.full_messages }, status: :unprocessable_entity
        end
      end

      def update
        if @song.update(song_params)
          render json: @song
        else
          render json: { errors: @song.errors.full_messages }, status: :unprocessable_entity
        end
      end

      def destroy
        @song.destroy
        head :no_content
      end

      private

      def set_song
        @song = Song.find(params[:id])
      end

      def song_params
        params.require(:song).permit(:title, :artist_id, :genre_id, :user_id, :original_key, :album_id, :content)
      end
    end
  end
end

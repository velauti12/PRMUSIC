module Api
  module V1
    class SongsController < BaseController
      before_action :authenticate_admin_token!, only: %i[update destroy]
      before_action :authenticate_token!, only: %i[create mine]
      before_action :set_song, only: %i[show update destroy transpose]
      before_action :ensure_visible!, only: %i[show transpose]

      # GET /api/v1/songs?q=texto&artist_id=1&genre_id=2
      # Solo canciones aprobadas. Filtros opcionales.
      def index
        songs = Song.approved.includes(*SONG_PRELOAD).search(params[:q])
        songs = songs.where(artist_id: params[:artist_id]) if params[:artist_id].present?
        songs = songs.where(genre_id: params[:genre_id]) if params[:genre_id].present?
        render json: songs.order(:title).map { |song| song_json(song) }
      end

      def show
        render json: song_json(@song)
      end

      # GET /api/v1/songs/mine — canciones aportadas por el usuario logueado (cualquier estado)
      def mine
        songs = @current_user.songs.includes(*SONG_PRELOAD).order(created_at: :desc)
        render json: songs.map { |song| song_json(song) }
      end

      # GET /api/v1/songs/:id/transpose?semitones=N
      def transpose
        semitones = params[:semitones].to_i
        render json: {
          id: @song.id,
          original_key: @song.original_key,
          semitones: semitones,
          key: @song.transposed_key(semitones),
          content: @song.transposed_content(semitones)
        }
      end

      # POST /api/v1/songs — el autor es siempre el usuario del token y queda en "pending"
      def create
        song = @current_user.songs.new(song_params.except(:user_id))
        song.status = :pending
        if song.save
          render json: song_json(song), status: :created
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

      # Una canción no aprobada solo la ve su autor o un admin; para el resto "no existe".
      def ensure_visible!
        return if @song.approved?

        user = current_user_from_token
        return if user && (user.admin? || @song.user_id == user.id)

        render json: { error: "Recurso no encontrado" }, status: :not_found
      end

      def song_params
        params.require(:song).permit(:title, :artist_id, :genre_id, :user_id, :original_key, :album_id, :content)
      end
    end
  end
end

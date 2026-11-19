module Admin
  class SongsController < BaseController
    before_action :set_song, only: %i[show edit update destroy approve reject]
    before_action :set_form_dependencies, only: %i[new edit create update]

    def index
      @status = params[:status].presence_in(Song.statuses.keys)
      @songs = Song.includes(:artist, :genre, :user, :album).order(:status, created_at: :desc)
      @songs = @songs.search(params[:q]) if params[:q].present?
      @songs = @songs.where(genre_id: params[:genre_id]) if params[:genre_id].present?
      @songs = @songs.where(status: @status) if @status
      @genres = Genre.order(:name)
      @status_counts = Song.group(:status).count
    end

    def show
      @semitones = params[:tono].to_i.clamp(-11, 11)
      @content = @song.transposed_content(@semitones)
      @key = @semitones.zero? ? @song.original_key : @song.transposed_key(@semitones)
    end

    def new
      @song = Song.new(status: :approved)
    end

    def create
      @song = Song.new(song_params)
      # Las canciones cargadas desde el back-office quedan a nombre de un admin
      @song.user ||= User.find_by(role: "admin")

      if @song.save
        redirect_to admin_song_path(@song), notice: "Canción \"#{@song.title}\" creada."
      else
        render :new, status: :unprocessable_entity
      end
    end

    def edit
    end

    def update
      if @song.update(song_params)
        redirect_to admin_song_path(@song), notice: "Cambios guardados."
      else
        render :edit, status: :unprocessable_entity
      end
    end

    def destroy
      title = @song.title
      @song.destroy
      redirect_to admin_songs_path, notice: "Canción \"#{title}\" borrada."
    end

    # Si el artista lo propuso un usuario y todavía no se revisó, se aprueba junto con la canción
    def approve
      new_artist = @song.artist.pending?
      Song.transaction do
        @song.artist.approved! if new_artist
        @song.approved!
      end
      message = "\"#{@song.title}\" aprobada. Ya se ve en el sitio."
      message += " También se aprobó el artista #{@song.artist.name}." if new_artist
      redirect_back fallback_location: admin_songs_path, notice: message
    end

    def reject
      @song.rejected!
      redirect_back fallback_location: admin_songs_path, notice: "\"#{@song.title}\" rechazada."
    end

    private

    def set_song
      @song = Song.find(params[:id])
    end

    def set_form_dependencies
      @artists = Artist.order(:name)
      @genres = Genre.order(:name)
      @albums = Album.includes(:artist).order(:title)
    end

    def song_params
      params.require(:song).permit(:title, :artist_id, :genre_id, :original_key, :album_id, :content, :status, :video_url)
    end
  end
end

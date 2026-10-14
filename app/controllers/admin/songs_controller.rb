module Admin
  class SongsController < BaseController
    before_action :set_song, only: %i[show edit update destroy approve reject]
    before_action :set_form_dependencies, only: %i[new edit create update]

    def index
      @songs = Song.includes(:artist, :genre, :user).order(created_at: :desc)
      @songs = @songs.search(params[:q]) if params[:q].present?
      @songs = @songs.where(genre_id: params[:genre_id]) if params[:genre_id].present?
      @genres = Genre.all
    end

    def show
    end

    def new
      @song = Song.new
    end

    def create
      @song = Song.new(song_params)
      @song.user ||= User.first

      if @song.save
        redirect_to admin_song_path(@song), notice: "Canción '#{@song.title}' creada con éxito."
      else
        render :new, status: :unprocessable_entity
      end
    end

    def edit
    end

    def update
      if @song.update(song_params)
        redirect_to admin_song_path(@song), notice: "Canción '#{@song.title}' actualizada con éxito."
      else
        render :edit, status: :unprocessable_entity
      end
    end

    def destroy
      title = @song.title
      @song.destroy
      redirect_to admin_songs_path, notice: "Canción '#{title}' eliminada exitosamente."
    end

    def approve
      @song.approved!
      redirect_to admin_songs_path, notice: "Canción '#{@song.title}' aprobada."
    end

    def reject
      @song.rejected!
      redirect_to admin_songs_path, notice: "Canción '#{@song.title}' rechazada."
    end

    private

    def set_song
      @song = Song.find(params[:id])
    end

    def set_form_dependencies
      @artists = Artist.order(:name)
      @genres = Genre.order(:name)
      @users = User.order(:username)
      @albums = Album.order(:title)
    end

    def song_params
      params.require(:song).permit(:title, :artist_id, :genre_id, :user_id, :original_key, :album_id, :content, :status)
    end
  end
end

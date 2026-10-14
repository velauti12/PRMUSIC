module Admin
  class ArtistsController < BaseController
    before_action :set_artist, only: %i[show edit update destroy]

    def index
      @artists = Artist.includes(:songs).order(:name)
    end

    def show
    end

    def new
      @artist = Artist.new
    end

    def create
      @artist = Artist.new(artist_params)
      if @artist.save
        redirect_to admin_artists_path, notice: "Artista '#{@artist.name}' creado correctamente."
      else
        render :new, status: :unprocessable_entity
      end
    end

    def edit
    end

    def update
      if @artist.update(artist_params)
        redirect_to admin_artists_path, notice: "Artista '#{@artist.name}' actualizado."
      else
        render :edit, status: :unprocessable_entity
      end
    end

    def destroy
      @artist.destroy
      redirect_to admin_artists_path, notice: "Artista eliminado."
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

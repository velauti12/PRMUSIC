module Admin
  # CRUD de álbumes con carga de portada (Active Storage).
  class AlbumsController < BaseController
    before_action :set_album, only: %i[edit update destroy]
    before_action :load_artists, only: %i[new create edit update]

    def index
      @albums = Album.includes(:artist, :songs, cover_attachment: :blob).order(:title)
    end

    def new
      @album = Album.new
    end

    def create
      @album = Album.new(album_params)
      if @album.save
        redirect_to admin_albums_path, notice: "Álbum '#{@album.title}' creado correctamente."
      else
        render :new, status: :unprocessable_entity
      end
    end

    def edit
    end

    def update
      if @album.update(album_params)
        # Solo se quita la portada si se marcó la casilla y no se subió una nueva
        @album.cover.purge_later if params.dig(:album, :remove_cover) == "1" && album_params[:cover].blank?
        redirect_to admin_albums_path, notice: "Álbum '#{@album.title}' actualizado."
      else
        render :edit, status: :unprocessable_entity
      end
    end

    def destroy
      @album.destroy
      redirect_to admin_albums_path, notice: "Álbum eliminado."
    end

    private

    def set_album
      @album = Album.find(params[:id])
    end

    def load_artists
      @artists = Artist.order(:name)
    end

    def album_params
      params.require(:album).permit(:title, :artist_id, :cover)
    end
  end
end

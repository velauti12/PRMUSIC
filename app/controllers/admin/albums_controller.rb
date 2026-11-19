module Admin
  # CRUD de álbumes. La tapa se puede subir a mano o elegir de las que encuentra Deezer
  # (se busca desde el mismo formulario con el título y el artista).
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
      if attach_found_cover && @album.save
        redirect_to admin_albums_path, notice: "Álbum \"#{@album.title}\" creado."
      else
        render :new, status: :unprocessable_entity
      end
    end

    def edit
    end

    def update
      @album.assign_attributes(album_params)
      if attach_found_cover && @album.save
        # Solo se quita la tapa si se marcó la casilla y no se eligió otra
        if params.dig(:album, :remove_cover) == "1" && album_params[:cover].blank? && params.dig(:album, :cover_url).blank?
          @album.cover.purge_later
        end
        redirect_to admin_albums_path, notice: "Álbum \"#{@album.title}\" actualizado."
      else
        render :edit, status: :unprocessable_entity
      end
    end

    def destroy
      @album.destroy
      redirect_to admin_albums_path, notice: "Álbum borrado."
    end

    # GET /admin/albums/cover_search?title=...&artist_id=... (lo usa el formulario)
    def cover_search
      artist = Artist.find_by(id: params[:artist_id])
      if params[:title].blank? || artist.nil?
        return render json: { error: "Completá el título y elegí el artista para buscar la tapa." }, status: :unprocessable_entity
      end

      results = CoverFinder.search(artist: artist.name, title: params[:title])
      render json: results.map(&:to_h)
    rescue CoverFinder::Error => e
      render json: { error: e.message }, status: :bad_gateway
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

    # Si se eligió una tapa de Deezer (y no se subió un archivo), la descarga y la adjunta
    def attach_found_cover
      url = params.dig(:album, :cover_url)
      return true if url.blank? || album_params[:cover].present?

      image = CoverFinder.download(url)
      @album.cover.attach(io: image, filename: "#{@album.title.to_s.parameterize}.jpg", content_type: "image/jpeg")
      true
    rescue CoverFinder::Error => e
      @album.errors.add(:cover, e.message)
      false
    end
  end
end

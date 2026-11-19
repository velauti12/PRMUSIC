module Admin
  class ArtistsController < BaseController
    before_action :set_artist, only: %i[edit update destroy approve merge]

    def index
      @artists = Artist.includes(:songs, :user).order(:status, :name)
    end

    def new
      @artist = Artist.new
    end

    def create
      @artist = Artist.new(artist_params)
      if @artist.save
        redirect_to admin_artists_path, notice: "Artista \"#{@artist.name}\" creado."
      else
        render :new, status: :unprocessable_entity
      end
    end

    def edit
      @others = Artist.approved.where.not(id: @artist.id).order(:name)
    end

    def update
      if @artist.update(artist_params)
        redirect_to admin_artists_path, notice: "Cambios guardados."
      else
        @others = Artist.approved.where.not(id: @artist.id).order(:name)
        render :edit, status: :unprocessable_entity
      end
    end

    def destroy
      @artist.destroy
      redirect_to admin_artists_path, notice: "Artista borrado."
    end

    def approve
      @artist.approved!
      redirect_back fallback_location: admin_artists_path, notice: "#{@artist.name} aprobado."
    end

    # Para cuando un usuario propuso un artista que ya estaba cargado (por ej. con otro nombre)
    def merge
      target = Artist.find(params[:target_id])
      name = @artist.name
      @artist.merge_into!(target)
      redirect_to edit_admin_artist_path(target), notice: "#{name} se unió con #{target.name}. Sus canciones y álbumes ahora son de #{target.name}."
    end

    private

    def set_artist
      @artist = Artist.find(params[:id])
    end

    def artist_params
      params.require(:artist).permit(:name, :bio, :status)
    end
  end
end

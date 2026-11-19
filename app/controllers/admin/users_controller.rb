module Admin
  class UsersController < BaseController
    def index
      @users = User.left_joins(:songs).group(:id)
                   .select("users.*, COUNT(songs.id) AS songs_count")
                   .order(:username)
    end

    def show
      @user = User.find(params[:id])
      @songs = @user.songs.includes(:artist).order(created_at: :desc)
      @favorites = @user.favorite_songs.includes(:artist).order(:title)
    end
  end
end

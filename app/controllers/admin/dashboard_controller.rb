module Admin
  class DashboardController < BaseController
    def index
      @songs_count = Song.count
      @artists_count = Artist.count
      @genres_count = Genre.count
      @users_count = User.count
      @recent_songs = Song.includes(:artist, :user, :genre).order(created_at: :desc).limit(5)
    end
  end
end

module Admin
  class DashboardController < BaseController
    def index
      @pending_songs = Song.pending.includes(:artist, :user).order(:created_at)
      @counts = {
        songs: Song.approved.count,
        artists: Artist.count,
        albums: Album.count,
        users: User.count
      }
      @recent_songs = Song.includes(:artist, :user).order(created_at: :desc).limit(5)
    end
  end
end

module Admin
  class UsersController < BaseController
    def index
      @users = User.includes(:songs, :favorites).order(:username)
    end

    def show
      @user = User.find(params[:id])
    end
  end
end

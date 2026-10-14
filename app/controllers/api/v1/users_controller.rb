module Api
  module V1
    class UsersController < ApplicationController
      before_action :authenticate_admin_token!, except: %i[index show create]
      before_action :set_user, only: %i[show update destroy]

      def index
        render json: User.all
      end

      def show
        render json: @user
      end

      def create
        user = User.new(user_params)
        user.role = "user" # Force role to be user for API registrations

        if user.save
          UserMailer.with(user: user).welcome_email.deliver_later
          render json: user, status: :created
        else
          render json: { errors: user.errors.full_messages }, status: :unprocessable_entity
        end
      end

      def update
        if @user.update(user_params)
          render json: @user
        else
          render json: { errors: @user.errors.full_messages }, status: :unprocessable_entity
        end
      end

      def destroy
        @user.destroy
        head :no_content
      end

      private

      def set_user
        @user = User.find(params[:id])
      end

      def user_params
        params.require(:user).permit(:username, :email, :password, :password_confirmation)
      end
    end
  end
end

class HomepageController < ApplicationController
  def index
      @user = User.new
  end

  def post_index
      if params[:signup]
        @user = User.new
        @user.newSmallUser
        if @user.save
          puts("SAVED")
        else
          redirect_to root_url
        end
      else
        puts('perform a login')
      end
    end

    private
  def user_params
    params.require(:user).permit(:email, :password)
  end
end

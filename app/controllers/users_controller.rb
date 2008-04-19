class UsersController < ApplicationController
  def show
    @user = User.find_by_login(params[:id])
  end
end

class UsersController < ApplicationController
	def show
		@user = User.find_by_login(params[:id])

		four_oh_four unless @user
	end
end

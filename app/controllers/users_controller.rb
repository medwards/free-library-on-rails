class UsersController < ApplicationController
	def show
		@user = User.find_by_login(params[:id])
		@items = @user.owned.paginate(:all, :page => params[:page], :order => 'title')

		four_oh_four unless @user
	end
end

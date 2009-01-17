# Copyright 2009 Michael Edwards, Brendan Taylor
# This file is part of free-library-on-rails.
# 
# free-library-on-rails is free software: you can redistribute it
# and/or modify it under the terms of the GNU Affero General Public
# License as published by the Free Software Foundation, either
# version 3 of the License, or (at your option) any later version.

# free-library-on-rails is distributed in the hope that it will be
# useful, but WITHOUT ANY WARRANTY; without even the implied
# warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
# See the GNU Affero General Public License for more details.
# 
# You should have received a copy of the GNU Affero General Public
# License along with free-library-on-rails.
# If not, see <http://www.gnu.org/licenses/>.

class AccountController < ApplicationController
	# If you want "remember me" functionality, add this before_filter to Application Controller
	before_filter :login_from_cookie

	before_filter :login_required, :only => [ :update ]

	# say something nice, you goof!  something sweet.
	def index
		redirect_to(:action => 'signup') unless logged_in?

		@user = current_user
	end

	def update
		@user = current_user

		# XXX user-specifiable attributes should be whitelisted, not
		# blacklisted with attr_protected like they are now
		if not @user.update_attributes(params[:user])
			error_list = "<ul><li>" + @user.errors.full_messages.join('</li><li>') + "</li></ul>"
			flash[:error] = "Couldn't update your settings: "
		else
			@user.tag_with params[:tags] if params[:tags]

			flash[:notice] = 'Updated your settings.'
		end

		redirect_to :action => 'index'
	end

	def login
		return unless request.post?
		self.current_user = User.authenticate(params[:login], params[:password])

		if logged_in?
			if params[:remember_me] == "1"
				self.current_user.remember_me
				cookies[:auth_token] = {
					:value => self.current_user.remember_token,
					:expires => self.current_user.remember_token_expires_at
				}
			end
			redirect_back_or_default(:controller => 'account', :action => 'index')

			flash[:notice] = "Logged in successfully."
		else
			user = User.find_by_login(params[:login])
			if user and not user.activated_at
				flash[:error] = "Couldn't log you in. You haven't activated your account."
			else
				flash[:error] = "Couldn't log you in. Check your username and password."
			end
		end
	end

	def signup
		return unless request.post?

		@user = User.new(params[:user])
		@user.login = params[:user][:login]

		@user.save!

		flash[:notice] = "Thanks for signing up! " \
			"We sent you an email with instructions on how to continue."

		UserNotifier.deliver_signup_notification(@user)

		redirect_back_or_default(:controller => 'welcome', :action => 'index')
	rescue ActiveRecord::RecordInvalid
		render :action => 'signup'
	end

	def logout
		self.current_user.forget_me if logged_in?
		cookies.delete :auth_token
		reset_session
		flash[:notice] = "You have been logged out."
		redirect_back_or_default(:controller => 'account', :action => 'login')
	end

	def activate
		flash.clear
		return if params[:id] == nil and params[:activation_code] == nil
		activator = params[:id] || params[:activation_code]

		@user = User.find_by_activation_code(activator)
		if @user and @user.activate
			redirect_back_or_default(:controller => 'account', :action => 'login')
			flash[:notice] = "Your account has been activated. Please login."
		else
			flash[:notice] = "Unable to activate the account. Please check or enter manually."
		end
	end
end

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

	# say something nice, you goof! something sweet.
	def index
		redirect_to(:action => 'signup') unless logged_in?

		@user = current_user
		@title = I18n.t 'account.index.title'
	end

	def update
		@user = current_user

		# XXX user-specifiable attributes should be whitelisted, not
		# blacklisted with attr_protected like they are now
		if not @user.update_attributes(params[:user])
			error_list = "<ul><li>" + @user.errors.full_messages.join('</li><li>') + "</li></ul>"
			flash[:error] = I18n.t 'account.update.message.not updated'
		else
			@user.tag_with params[:tags] if params[:tags]

			flash[:notice] = I18n.t 'account.update.message.updated'
		end

		redirect_to :action => 'index'
	end

	def login
		unless request.post?
			@title = I18n.t 'account.login.title'

			# after login, redirect to the last URL they were at
			# FIXME: it would be really nice not to have the special case for reset_password...
			if request.referer and not request.referer.match /reset_password/
				session[:return_to] = request.referer
			end

			# go straight to the view
			return
		end

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

			flash[:notice] = I18n.t 'account.login.message.logged in'
		else
			user = User.find_by_login(params[:login])
			if user and not user.activated_at
				flash[:error] = I18n.t 'account.login.message.not activated'
			else
				flash[:error] = I18n.t 'account.login.message.check user and password'
			end
		end
	end

	def signup
		@title = I18n.t 'account.signup.title'
		return unless request.post?

		@user = User.new(params[:user])
		@user.login = params[:user][:login]

		UserNotifier.deliver_signup_notification(@user)

		@user.save!

		flash[:notice] = I18n.t 'account.signup.message.email sent'

		redirect_back_or_default(:controller => 'welcome', :action => 'index')
	rescue ActiveRecord::RecordInvalid
		render :action => 'signup'
	end

	def reset_password
		if request.post?
			user = User.find_by_email params[:email]

			if user
				user.reset_password!
				flash[:notice] = I18n.t 'account.reset password.message.email sent'
			else
				flash[:error] = I18n.t 'account.reset password.message.wrong email'
			end

			session[:return_to] = nil
			redirect_to :controller => 'account', :action=> 'login'
		end
	end

	def logout
		self.current_user.forget_me if logged_in?
		cookies.delete :auth_token
		reset_session
		flash[:notice] = I18n.t 'account.logout.message.logged out'
		redirect_back_or_default(:controller => 'account', :action => 'login')
	end

	def activate
		flash.clear
		return if params[:id] == nil and params[:activation_code] == nil
		activator = params[:id] || params[:activation_code]

		@user = User.find_by_activation_code(activator)
		if @user and @user.activate
			flash[:notice] = I18n.t 'account.activate.message.activated'
			redirect_back_or_default(:controller => 'account', :action => 'login')
		else
			flash[:notice] = I18n.t 'account.activate.message.not activated'
			redirect_to(:controller => 'account', :action=> 'login')
		end
	end
end

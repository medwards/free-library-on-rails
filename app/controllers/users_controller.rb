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

require 'csv'

class UsersController < ApplicationController

	before_filter :login_required

	def show
		@user = User.find_by_login(params[:id])
		four_oh_four and return unless @user

		respond_to do |format|
			format.html do
				@items = @user.owned.paginate(:page => params[:page], :order => 'title')

				@title = @user.login
			end
			format.csv do
				@items = @user.owned.order(:id)
				render :layout => false
			end
		end
	end

	def search
		@user = User.find_by_login(params[:id])
		@query = params[:q]

		# fields to search
		@fields = [ params[:field] ]
		@fields ||= [ 'tags', 'title', 'author', 'description' ]

		# TODO this needs the user_id condition, i'm too lazy to add it right now.
		# if @fields.member? 'tags'
		#	@tag_results = Item.find_by_tag(@query).paginate(:page => params[:page])
		# end

		extra_conditions = 'AND owner_id = ?'
		extra_terms	= [@user]

		terms = @query.split(' ')

		if @fields.member? 'title'
			@title_results = Item.paginated_search_title params[:page],
														 terms,
														 extra_conditions,
														 extra_terms
		end

		if @fields.member? 'author'
			@author_results = Item.paginated_search_author params[:page],
														   terms,
														   extra_conditions,
														   extra_terms
		end

		if @fields.member? 'description'
			@description_results = Item.paginated_search_description params[:page],
																	 terms,
																	 extra_conditions,
																	 extra_terms
		end
	end

	def comments
		@user = User.find_by_login(params[:id])

		@user.comments.create :author_id => current_user.id, :text => params[:text], :created => Time.now

		redirect_to :action => :show
	end

	def librarian
		@user = User.find_by_login(params[:id])

		if not @user.librarian?
			User.transaction do
				@user.update_attributes! librarian_since: Time.now
				UserMailer.librarian_notification(@user, current_user)
			end
			flash[:notice] = I18n.t 'account.librarian.message.made librarian', user: @user.login
		else
			flash[:notice] = I18n.t 'account.librarian.message.already librarian', user: @user.login
		end

		redirect_to :action => :show
	end
end

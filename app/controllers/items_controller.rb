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

class ItemsController < ApplicationController
	before_filter :login_required, :only => [ :new, :create, :destroy, :edit, :update ]

	def itemclass; Item end

	def index
		@items = region.items.paginate(:all, :page => params[:page],
									   :order => 'title',
									   :conditions => { :type => itemclass.to_s })
	end

	def show
		@item = itemclass.find(params[:id])
	rescue ActiveRecord::RecordNotFound
		four_oh_four
	end

	def new
		@item = itemclass.new(params[:item])

		@tags = params[:tags]
		@tags ||= []
	end

	def create
		@item = itemclass.new(params[:item])

		@item.created = Time.now
		@item.owner = self.current_user

		@item.save!

		@item.tag_with params[:tags] if params[:tags]

		redirect_to :controller => itemclass.to_s.tableize, :action => 'show', :id => @item
	end

	def edit
		@item = itemclass.find(params[:id])

		unless @item.owned_by? self.current_user
			redirect_to polymorphic_path(@item)
		end
	rescue ActiveRecord::RecordNotFound
		four_oh_four
	end

	def update
		@item = itemclass.find(params[:id])

		unless @item.owned_by? self.current_user
			unauthorized 'not authorized to edit this item'; return
		end

		itemclass.update(params[:id], params[:item])

		@item.tag_with params[:tags]

		redirect_to polymorphic_path(@item)
	end

	def destroy
		@item = Item.find(params[:id])

		unless @item.owned_by? self.current_user
			unauthorized 'not authorized to edit this item'; return
		end

		@item.destroy

		# XXX this has behaved weird anecdotally... come back to it and test
		redirect_to user_path(self.current_user.login)
	end

	# plain ?param=value parameters:
	#	q:		the search term
	#	field:	fields to search
	#	page:	pagination
	def search
		@query = params[:q]

		# fields to search
		@fields = params[:field]
		@fields ||= [ 'tags', 'title', 'author', 'description' ]

		if @fields.member? 'tags'
			@tag_results = itemclass.find_by_tag(@query).paginate(:page => params[:page])
		end

		terms = @query.split(' ')
		wildcards = terms.map { |t| "%#{t}%" }

		if @fields.member? 'title'
			t_cond = (['title LIKE ?'] * wildcards.length).join(' AND ')

			@title_results = itemclass.paginate :all,
				:page => params[:page],
				:order => :title,
				:conditions => [t_cond, *wildcards]
		end

		if @fields.member? 'author'
			a_cond = (['author_first LIKE ? OR author_last LIKE ?'] * wildcards.length).join(' AND ')

			@author_results = itemclass.paginate :all,
				:page => params[:page],
				:order => :title,
				:conditions => [a_cond, *(wildcards.map{ |x| [x] * 2 }.flatten)]
		end

		if @fields.member? 'description'
			d_cond = (['description LIKE ?'] * wildcards.length).join(' AND ')

			@description_results = itemclass.paginate :all,
				:page => params[:page],
				:order => :title,
				:conditions => [d_cond, *wildcards]
		end
	end
end

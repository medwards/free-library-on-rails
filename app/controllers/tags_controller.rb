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

class TagsController < ApplicationController
	def index
		@title = I18n.t 'tags.index.title'
		@tag_counts = ItemTagging.counts
	end

	def show
		@tag = Tag.find_by_name(params[:id])

		return four_oh_four unless @tag

		@title = I18n.t('tags.show.title', :tag => @tag.name)
		@items = @tag.items.paginate(:page => params[:page])
	end

	def autocomplete
		@tags = Tag.search(params[:term]||params[:q]).paginate(:page => params[:page])
		render json: @tags.map(&:name)
	end
end

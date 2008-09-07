class TagsController < ApplicationController
	def index
		@tags = Tag.only_used.paginate(:page => params[:page])
	end

	def show
		@tag = Tag.find_by_name(params[:id])

		return four_oh_four unless @tag

		@items = @tag.items
	end
end

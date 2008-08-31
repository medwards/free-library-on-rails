class TagsController < ApplicationController
	def index
		@tags = Tag.only_used
	end

	def show
		@tag = Tag.find_by_name(params[:id])
		@items = @tag.items
	end
end

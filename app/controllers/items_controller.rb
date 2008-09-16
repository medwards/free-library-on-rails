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

		q = "%#{@query}%"

		if @fields.member? 'title'
			@title_results = itemclass.paginate :all, :page => params[:page], :order => :title,
				:conditions => [ 'title LIKE ?', q ]
		end

		if @fields.member? 'author'
			@author_results = itemclass.paginate :all, :page => params[:page], :order => :title,
				:conditions => [ 'author_first LIKE ? OR author_last LIKE ?', q, q ]
		end

		if @fields.member? 'description'
			@description_results = itemclass.paginate :all, :page => params[:page], :order => :title,
				:conditions => [ 'description LIKE ?', q ]
		end
	end
end

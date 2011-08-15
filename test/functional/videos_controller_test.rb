require 'test_helper'

class VideosControllerTest < ActionController::TestCase
	include AuthenticatedTestHelper

	def setup
		@controller = VideosController.new
		@request    = ActionController::TestRequest.new
		@response   = ActionController::TestResponse.new
	end

	def test_routing
		assert_routing 'items/3', :controller => 'items', :action => 'show', :id => '3'
		assert_routing 'videos/1', :controller => 'videos', :action => 'show', :id => '1'

		assert_routing 'videos/new', :controller => 'videos', :action => 'new'
	end

	def test_show
		get :show, :id => items(:sg)
		assert_response :success

		assert_match /Soylent Green/, @response.body
	end

	# should be able to GET the create form
	def test_new
		login_as 'bct'
		get :new

		assert_response :success
	end

	def test_create
		old_count = Item.count

		login_as 'bct'

		# the number of items in the database should increase after a POST
		assert_difference(Item, :count, 1) do
		  post :create, :item => {
								  :title => "Logan's Run"
								  }
		end

		new_video = Video.find_by_title("Logan's Run")

		assert_redirected_to :controller => 'videos', :action => 'show', :id => new_video

		# you should be able to GET the new item
		get :show, :id => new_video
		assert_response :success

		assert_match /Logan's Run/, @response.body
	end

	  # you can't create an item unless you're logged in
	def test_unauthenticated_create
		assert_difference(Item, :count, 0) do
		  post :create, :item => {
								  :title => "Logan's Run"
								  }
		end

		assert_response 302
	end
end

require 'test_helper'

class TagsControllerTest < ActionController::TestCase
	def setup
		@controller = TagsController.new
		@request    = ActionController::TestRequest.new
		@response   = ActionController::TestResponse.new
	end

	def test_routing
		assert_routing 'tags', :controller => 'tags', :action => 'index'
		assert_routing 'tags/politics', :controller => 'tags', :action => 'show', :id => 'politics'
	end

	def test_index
		get :index, :id => items(:lhd)
		assert_response :success

		assert_match /politics/, @response.body
		assert_match /spain/, @response.body
	end

	def test_show
		get :show, :id => 'politics'
		assert_response :success

		assert_match /Homage to Catalonia/, @response.body
		assert_match /Soylent Green/, @response.body
	end
end

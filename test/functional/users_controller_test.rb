require File.dirname(__FILE__) + '/../test_helper'

class UsersControllerTest < ActionController::TestCase
	def setup
		@controller = UsersController.new
		@request    = ActionController::TestRequest.new
		@response   = ActionController::TestResponse.new
	end

	def test_routing
		assert_routing 'users/bct', :controller => 'users', :action => 'show', :id => 'bct'
	end

	def test_show
		get :show, :id => 'bct'

		assert_response :success

		assert_match /bct/, @response.body

		# should be able to get a list of owned books
		assert_match /Homage to Catalonia/, @response.body
	end

	def test_search
		get :search, :q => 'catalonia homage', :field => 'title', :id => 'bct'

		assert_response :success

		assert_match /Homage to Catalonia/, @response.body
	end
end

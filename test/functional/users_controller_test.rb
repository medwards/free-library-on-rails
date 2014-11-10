require 'test_helper'

class UsersControllerTest < ActionController::TestCase
	include AuthenticatedTestHelper

	def setup
		@controller = UsersController.new
		@request    = ActionController::TestRequest.new
		@response   = ActionController::TestResponse.new
		login_as 'bct'
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

	def test_show_comments
		get :show, :id => 'medwards'

		assert_response :success

		assert_match /A Rad Dude./, @response.body
	end

	def test_make_librarian
		login_as 'john'
		post :librarian, :id => 'bct'

		bct = User.find_by_login('bct')
		assert_response 302
		assert_equal true, bct.librarian?
	end
end

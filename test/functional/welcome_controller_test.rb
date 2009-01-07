require File.dirname(__FILE__) + '/../test_helper'

class WelcomeControllerTest < Test::Unit::TestCase
	def setup
		@controller = WelcomeController.new
		@request    = ActionController::TestRequest.new
		@response   = ActionController::TestResponse.new
	end

	def test_routing
		assert_routing '', :controller => 'welcome', :action => 'index'
		assert_routing 'about', :controller => 'welcome', :action => 'about'
		assert_routing 'new', :controller => 'welcome', :action => 'new_things'
	end

	def test_index
		get :index

		assert_response :success
	end

	def test_about
		get :about

		assert_response :success
	end

	def test_new
		get :new_things

		assert_response :success
	end
end

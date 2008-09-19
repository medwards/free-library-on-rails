require File.dirname(__FILE__) + '/../test_helper'

class BooksControllerTest < Test::Unit::TestCase
	include AuthenticatedTestHelper

	def setup
		@controller = BooksController.new
		@request    = ActionController::TestRequest.new
		@response   = ActionController::TestResponse.new
	end

	def test_routing
		assert_routing 'items/1', :controller => 'items', :action => 'show', :id => '1'
		assert_routing 'books/1', :controller => 'books', :action => 'show', :id => '1'

		assert_routing 'books/new', :controller => 'books', :action => 'new'
	end

	def test_show
		get :show, :id => items(:lhd)
		assert_response :success

		assert_match /Left Hand of Darkness/, @response.body
	end

	# should be able to GET the create form
	def test_new
		login_as 'bct'
		get :new

		assert_response :success
	end

	# unauthenticated users get sent to the login form
	def test_unauth_new
		get :new

		assert_response 302
	end

	def test_create
		old_count = Item.count

		login_as 'bct'

		# the number of items in the database should increase after a POST
		assert_difference(Item, :count, 1) do
		  post :create, :item => {
								  :title => 'Iron Council'
								  },
						:tags => 'political, fiction'
		end

		new_book = Book.find_by_title('Iron Council')

		assert_equal ['fiction', 'political'], new_book.tags.sort

		assert_redirected_to :controller => 'books', :action => 'show', :id => new_book

		# you should be able to GET the new item
		get :show, :id => new_book
		assert_response :success

		assert_match /Iron Council/, @response.body
	end

	# you can't create an item unless you're logged in
	def test_unauthenticated_create
		assert_difference(Item, :count, 0) do
		  post :create, :item => {
								  :title => 'Iron Council'
								  }
		end

		assert_response 302
	end

	# you can destroy your items
	def test_destroy
		login_as 'bct'

		item = items(:htc)

		assert_difference(Item, :count, -1) do
		  delete :destroy, :id => item
		end

		# it's gone now
		get :show, :id => item

		assert_response 404
	end

	# you can't destroy another user's item
	def test_unauthorized_destroy
		login_as 'bct'

		item = items(:lhd)

		assert_difference(Item, :count, 0) do
		  delete :destroy, :id => item
		end

		assert_response 401
	end

	def test_edit
		login_as 'bct'

		htc = items(:htc)

		get :edit, :id => htc
		assert_response :success

		put :update, :id => htc, :item => { :title => 'something new' }, :tags => 'new ,tags'

		assert_redirected_to :controller => 'books', :action => 'show', :id => htc

		item = Book.find(htc)
		assert_equal 'something new', item.title
		assert_equal ['new', 'tags'], item.tags.sort
	end

	def test_unauthorized_edit
		login_as 'bct'

		lhd = items(:lhd)

		get :edit, :id => lhd
		assert_redirected_to :controller => 'books', :action => 'show', :id => lhd

		put :update, :id => lhd, :item => { :title => 'haxored' }, :tags => 'pwned lol'
		assert_response 401

		lhd = Book.find(lhd)
		assert_equal 'The Left Hand of Darkness', lhd.title
		assert_equal [], lhd.tags.sort
	end

	def test_search_title
		get :search, :q => 'catalonia homage', :field => 'title'

		assert_response :success

		assert_match /Homage to Catalonia/, @response.body
	end

	def test_search_author
		get :search, :q => 'guin ursula', :field => 'author'

		assert_response :success

		assert_match /The Left Hand of Darkness/, @response.body
	end
end

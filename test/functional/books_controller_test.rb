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
    get :show, :id => 1
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
                              :type => 'book',
                              :title => 'Iron Council'
                              }
    end

    # i'm foolishly assuming the next ID is 3 here
    assert_redirected_to :action => :show, :id => 3

    # you should be able to GET the new item
    get :show, :id => 3
    assert_response :success

    assert_match /Iron Council/, @response.body
  end

  # you can't create an item unless you're logged in
  def test_unauthenticated_create
    assert_difference(Item, :count, 0) do
      post :create, :item => {
                              :type => 'book',
                              :title => 'Iron Council'
                              }
    end

    assert_response 302
  end

  # you can destroy your items
  def test_destroy
    login_as 'bct'

    assert_difference(Item, :count, -1) do
      delete :destroy, :id => 2
    end

    # it's gone now
    get :show, :id => 2

    assert_response 404
  end

  # you can't destroy another user's item
  def test_unauthorized_destroy
    login_as 'bct'

    assert_difference(Item, :count, 0) do
      delete :destroy, :id => 1
    end

    # XXX this is expected to fail for now
    assert_response 401
  end
end

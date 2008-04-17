require File.dirname(__FILE__) + '/../test_helper'

class ItemsControllerTest < Test::Unit::TestCase
  include AuthenticatedTestHelper

  def setup
    @controller = ItemsController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end

  def test_routing
    assert_routing 'items/1', :controller => 'items', :action => 'show', :id => '1'
  end

  def test_show
    get :show, :id => 1
    assert_response :success

    assert_match /Left Hand of Darkness/, @response.body
  end

  # should be able to GET the create form
  def test_new
    get :new
    assert_response :success
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

    # i'm foolishly assuming the next ID is 2 here
    assert_redirected_to :action => :show, :id => 2

    # you should be able to GET the new item
    get :show, :id => 2
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

    assert_response 401
  end
end

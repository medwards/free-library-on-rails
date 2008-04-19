require File.dirname(__FILE__) + '/../test_helper'

class AccountControllerTest < Test::Unit::TestCase
  include AuthenticatedTestHelper

  def setup
    @controller = AccountController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end

  def test_routing
    assert_routing 'account', :controller => 'account', :action => 'index'
    assert_routing 'account/signup', :controller => 'account', :action => 'signup'
    assert_routing 'account/login', :controller => 'account', :action => 'login'
  end

  def test_show_unauthenticated
    get :index

    assert_response 302
  end

  def test_show
    login_as 'bct'
    get :index

    assert_response :success
  end

  def test_signup
    get :signup

    assert_response :success
  end

  def test_login
    get :signup

    assert_response :success
  end

  def test_update
    login_as 'bct'

    assert_difference(User, :count, 0) do
      post :update, :user => { :cellphone => '7807086602' }
    end

    assert_response 302

    assert_equal '7807086602', User.find_by_login('bct').cellphone
  end

  def test_update_unauthenticated
    post :update, :user => { :cellphone => '7807086602' }

    assert_response 302
  end

  # try to change attributes that shouldn't be changeable
  def test_update_protected_attributes
    login_as 'bct'

    post :update, :user => { :id                        => 1337,
                             :created_at                => '2008-04-20',
                             :updated_at                => '2008-04-20',
                             :activated_at              => '2008-04-20',
                             :login                     => 'somebody-else'
                          }

    assert_response 302

    bct = User.find_by_login('bct')

    assert_not_nil bct, 'user was able to rename themself'
    assert_equal 0, bct.id
    assert_equal 'bct', bct.login
    assert_equal Time.parse('2008-04-01'), bct.created_at
    assert_equal Time.parse('2008-04-01'), bct.activated_at

    assert((Time.now - bct.updated_at).abs < 5)
  end
end

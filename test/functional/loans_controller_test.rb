require File.dirname(__FILE__) + '/../test_helper'

class LoansControllerTest < Test::Unit::TestCase
  include AuthenticatedTestHelper

  def setup
    @controller = LoansController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end

  def test_no_login
    get :new
    assert_redirected_to :controller => 'account', :action => 'login'

    post :create
    assert_redirected_to :controller => 'account', :action => 'login'
  end

  def test_request
    sg = items(:sg)

    login_as 'pierre'

    get :new, :item_id => sg.id
    assert_response :success

    assert_difference(Loan, :count, 1) do
      post :create, :item_id => sg.id
    end

    assert_redirected_to :controller => 'videos', :action => 'show', :id => sg.id.to_s
  end

  def test_index
    get :index
    assert_redirected_to :controller => 'account', :action => 'login'

    login_as 'bct'

    get :index
    assert_response :success
  end
end

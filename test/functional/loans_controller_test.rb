require File.dirname(__FILE__) + '/../test_helper'

class LoansControllerTest < ActionController::TestCase
	include AuthenticatedTestHelper

	def setup
		@controller = LoansController.new
		@request	= ActionController::TestRequest.new
		@response	= ActionController::TestResponse.new
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

	def test_approve
		request = loans(:request)
		htc = items(:htc)

		login_as 'bct'

		put :update, :id => request, :return_date => '2012-12-21'
		assert_redirected_to :controller => 'books', :action => 'show', :id => htc.id.to_s

		# loan was approved
		loan = Loan.find(request)
		assert_equal "lent", loan.status

		book = Book.find(htc)
		assert_equal loan, book.current_loan
	end

	def test_reject
		request = loans(:request)
		htc = items(:htc)

		login_as 'bct'

		put :update, :id => request, :status => 'rejected'
		assert_redirected_to :controller => 'books', :action => 'show', :id => htc.id.to_s

		# loan was rejected
		loan = Loan.find(request)
		assert_equal 'rejected', loan.status

		book = Book.find(htc)
		assert_nil book.current_loan
	end

	def test_approve_already_lent
		loan = loans(:loan)
		request = loans(:lhd_req)
		lhd = items(:lhd)

		login_as 'medwards'

		put :update, :id => request, :return_date => '2012-12-21'
		assert_redirected_to :controller => 'books', :action => 'show', :id => lhd.id.to_s

		# loan was not approved
		request = Loan.find(request)
		assert_equal 'requested', request.status

		# original loan is still intact
		loan = Loan.find(loan)
		assert_equal 'lent', loan.status

		book = Book.find(lhd)
		assert_equal loan, book.current_loan
	end

	def test_unauthorized_approve
		request = loans(:request)
		htc = items(:htc)

		put :update, :id => request, :return_date => '2012-12-21'
		assert_response 302

		# loan was not approved
		loan = Loan.find(request)
		assert_equal 'requested', loan.status

		book = Book.find(htc)
		assert_nil book.current_loan
	  end

	def test_returned
		loan = loans(:loan)
		lhd = items(:lhd)

		login_as 'medwards'

		put :update, :id => loan
		assert_redirected_to :controller => 'books', :action => 'show', :id => lhd.id.to_s

		# item was marked returned
		loan = Loan.find(loan)
		assert_equal 'returned', loan.status

		book = Book.find(lhd)
		assert_nil book.current_loan
	  end

	def test_loan_to_self
		htc = items(:htc)

		login_as 'bct'

		assert_difference(Loan, :count, 1) do
		  post :create, :item_id => htc.id, :return_date => '2012-12-21', :memo => 'lent to dad'
		end

		assert_redirected_to :controller => 'books', :action => 'show', :id => htc.id.to_s

		book = Book.find(htc)

		# loan was automatically made
		loan = book.current_loan

		assert_not_nil loan
		assert_equal "lent", loan.status

		assert_equal 'lent to dad', loan.memo
	end
end

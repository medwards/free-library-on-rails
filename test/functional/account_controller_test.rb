require 'test_helper'

class AccountControllerTest < ActionController::TestCase
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

	def test_show_signup
		get :signup

		assert_response :success
	end

	def test_do_signup
		assert_difference(User, :count, 1) do
			post :signup, :user => { :login => 'stnick',
									 :email => 'nick@example.org',
									 :password => 'elves',
									 :password_confirmation => 'elves',
									 :postalcode => 'H0H 0H0',
									 :longitude => '0.12',
									 :latitude => '1.23' }
		end

		assert_redirected_to root_path

		nick = User.find_by_login('stnick')

	end

	def test_login
		get :login

		assert_response :success
	end

	def test_update
		login_as 'bct'

		assert_difference(User, :count, 0) do
		  post :update, :user => { :cellphone => '7807086602', :email => 'new-bct@example.org' }
		end

		assert_response 302

		bct = User.find_by_login('bct')
		assert_equal '7807086602', bct.cellphone
		assert_equal 'new-bct@example.org', bct.email
	end

	def test_update_password_no_confirm
		login_as 'bct'

		bct = User.find_by_login('bct')
		orig = bct.crypted_password

		assert_difference(User, :count, 0) do
		  post :update, :user => { :password => 'test' }
		end

		assert_response 302
		assert @request.flash[:error]

		# password was not updated
		bct = User.find_by_login('bct')
		assert_equal orig, bct.crypted_password
	end

	def test_update_password_bad_confirm
		login_as 'bct'

		bct = User.find_by_login('bct')
		orig = bct.crypted_password

		assert_difference(User, :count, 0) do
		  post :update, :user => { :password => 'test', :password_confirmation => 'oops' }
		end

		assert_response 302
		assert @request.flash[:error]

		# password was not updated
		bct = User.find_by_login('bct')
		assert_equal orig, bct.crypted_password
	end

	def test_update_password
		# correct confirmation included
		login_as 'bct'

		bct = User.find_by_login('bct')
		orig = bct.crypted_password

		assert_difference(User, :count, 0) do
		  post :update, :user => { :password => 'test', :password_confirmation => 'test' }
		end

		assert_response 302
		assert @request.flash[:notice]

		bct = User.find_by_login('bct')
		assert bct.authenticated?('test')
	end

	def test_update_unauthenticated
		post :update, :user => { :cellphone => '7807086602' }

		assert_response 302
	end

	# try to change attributes that shouldn't be changeable
	def test_update_protected_attributes
		login_as 'bct'

		old_user = User.find_by_login('bct')
		old_user.touch

		post :update, :user => { :id                        => 1337,
								 :created_at                => '2008-04-20',
								 :updated_at                => '2008-04-20',
								 :activated_at              => '2008-04-20',
								 :librarian_since           => '2008-04-20',
								 :login                     => 'somebody-else'
							  }

		# the update should succeed but nothing should change
		assert_response 302

		bct = User.find_by_login('bct')

		assert_not_nil bct, 'user was able to rename themself'
		assert_equal old_user.id, bct.id
		assert_equal 'bct', bct.login
		assert_equal Time.zone.parse('2008-04-01'), bct.created_at
		assert_equal Time.zone.parse('2008-04-01'), bct.activated_at
		assert_nil bct.librarian_since

		assert (Time.now - bct.updated_at).abs < 5, 'user was able to change updated_at'
	end

	def test_tag
		login_as 'bct'

		assert_difference(User, :count, 0) do
		  post :update, :tags => 'funny hats, celery'
		end

		assert_response 302
		assert @request.flash[:notice]

		bct = User.find_by_login('bct')
		assert bct.tags.map(&:to_s).member?('funny hats')
		assert bct.tags.map(&:to_s).member?('celery')
	end

	def test_reset_password
		get :reset_password

		assert_response 200

		bct = User.find_by_login 'bct'
		old_passwd = bct.crypted_password

		post :reset_password, :email => bct.email
		assert_redirected_to :controller => 'account', :action => 'login'
		assert @request.flash[:notice], 'Notice was not given to the user.'

		bct = User.find_by_login 'bct'
		assert_not_equal old_passwd, bct.crypted_password
	end

	def test_reset_password_bad_email
		post :reset_password, :email => 'some-email-that@doesnt-exist.example'

		assert_redirected_to :controller => 'account', :action => 'login'
		assert @request.flash[:error], 'User was not notified of error.'
	end

	def test_request_activation
		post :request_activation, :email => 'test@example.org'

		assert_response 302
		assert_match I18n.t('account.request activation.message.sent'), @request.flash[:notice]
	end

	def test_librarian_giveup
		login_as 'john'
		post :leave_librarian

		john = User.find_by_login('john')
		assert_equal false, john.librarian?
	end
end

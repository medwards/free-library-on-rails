class UserNotifier < ActionMailer::Base
	def signup_notification(user)
		setup_email(user)
		@subject		+= 'Free Library Account Request'
		@body[:url]  = "http://localhost:3000/account/activate/#{user.activation_code}"
	end

	def activation(user)
		setup_email(user)
		@subject		+= 'Your Free Library account has been activated!'
		@body[:url]  = "http://freelibrary.ca/"
	end

	protected
	def setup_email(user)
		@recipients  = "#{user.email}"
		@from				 = "admin@freelibrary.ca"
		@subject		 = "[efl] "
		@sent_on		 = Time.now
		@body[:user] = user
	end
end

# Copyright 2009 Michael Edwards, Brendan Taylor
# This file is part of free-library-on-rails.
# 
# free-library-on-rails is free software: you can redistribute it
# and/or modify it under the terms of the GNU Affero General Public
# License as published by the Free Software Foundation, either
# version 3 of the License, or (at your option) any later version.

# free-library-on-rails is distributed in the hope that it will be
# useful, but WITHOUT ANY WARRANTY; without even the implied
# warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
# See the GNU Affero General Public License for more details.
# 
# You should have received a copy of the GNU Affero General Public
# License along with free-library-on-rails.
# If not, see <http://www.gnu.org/licenses/>.

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

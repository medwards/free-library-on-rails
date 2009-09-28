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
	include ActionController::UrlWriter

	# FIXME these should go somewhere that's easy to configure
	FROM_ADDRESS = "admin@freelibrary.ca"
	SUBJECT_PREFIX = "[efl] "
	default_url_options[:host] = 'freelibrary.ca'

	def signup_notification(user)
		setup_email(user)
		@subject	+= 'Free Library Account Request'
		@body[:url]	+= "/account/activate/#{user.activation_code}"
	end

	def password_reset_notification(user, new_password)
		setup_email(user)
		@subject += " Password Reset Request"
		@body[:new_password] = new_password
	end

	protected
	def setup_email(user)
		@recipients		= user.email
		@from			= FROM_ADDRESS
		@subject		= SUBJECT_PREFIX
		@sent_on		= Time.now
		@body[:user] = user
		@body[:url] = "http://freelibrary.ca"
	end
end

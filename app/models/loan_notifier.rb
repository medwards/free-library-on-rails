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

class LoanNotifier < ActionMailer::Base
	include ActionController::UrlWriter
	# FIXME this should go somewhere that's easy to configure
	default_url_options[:host] = 'freelibrary.ca'

	def request_notification(loan)
		setup_email(loan.item.owner)
		@from		= loan.borrower.email
		@subject   += 'Loan Request'
		@owner		= loan.item.owner.login
		@borrower	= loan.borrower.login
		@item		= "#{loan.item.title} by " +
			"#{loan.item.author_first} #{loan.item.author_last}"

		@item_url	= polymorphic_path(loan.item, :only_path => false)
		@loans_url	= loans_path(:only_path => false)
	end

	def approved_notification(loan)
		setup_email(loan.borrower)
		@subject		+= 'Loan Approved'
		@owner = "#{loan.item.owner.login}"
		@from = "#{loan.item.owner.email}"
		@title = "#{loan.item.title}"
		@author = "#{loan.item.author_first} #{loan.item.author_last}"
		@body[:url]  = "http://localhost:3000/#{loan.item.type.downcase}/#{loan.item.id}"
		@body[:url2]	= "http://localhost:3000/loans"
	end

	def rejected_notification(loan)
		setup_email(loan.borrower)
		@subject		+= 'Loan Not Approved'
		@from = "#{loan.item.owner.email}"
		@title = "#{loan.item.title}"
		@author = "#{loan.item.author_first} #{loan.item.author_last}"
		@body[:url]  = "http://localhost:3000/#{loan.item.type.downcase}/#{loan.item.id}"
		@body[:url2]	= "http://localhost:3000/loans"
	end

	protected
	def setup_email(user)
		@recipients	= user.email
		@from		= "admin@freelibrary.ca"
		@subject	= "[Free Library] "
		@sent_on	= Time.now
		@body[:user] = user
	end
end

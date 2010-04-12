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
		setup_email(loan)
		@recipients = loan.owner.email
		@from		= loan.borrower.email
		@subject   += I18n.t 'loans.loan request'
	end

	def approved_notification(loan)
		setup_email(loan)
		@recipients = loan.borrower.email
		@from		= loan.owner.email
		@subject   += I18n.t 'loans.loan approved'
	end

	def rejected_notification(loan)
		setup_email(loan)
		@recipients = loan.borrower.email
		@subject   += I18n.t 'loans.loan not approved'
	end

	protected
	def setup_email(loan)
		@from		= "admin@freelibrary.ca"
		@subject	= "[#{I18n.t 'emails.email label'}] "
		@sent_on	= Time.now

		@body[:owner]		= loan.owner.login
		@body[:borrower]	= loan.borrower.login

		@body[:item]		= "\"#{loan.item.title}\" #{I18n.t 'emails.by'} " +
			"#{loan.item.author_first} #{loan.item.author_last}"

		# FIXME: don't hardcode urls, blah blah blah
		@body[:item_url]	= 'http://freelibrary.ca' + polymorphic_path(loan.item)
		@body[:loans_url]	= 'http://freelibrary.ca' + loans_path
	end
end

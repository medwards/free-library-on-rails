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

class LoanMailer < ApplicationMailer

	def request_notification(loan)
		setup_email(loan)
		@subject += I18n.t 'loans.email.request'
		mail :reply_to => loan.borrower.email, :to => loan.owner.email, :subject => @subject
	end

	def approved_notification(loan)
		setup_email(loan)
		@subject += I18n.t 'loans.email.approved'
		mail :reply_to => loan.owner.email, :to => loan.borrower.email, :subject => @subject
	end

	def rejected_notification(loan)
		setup_email(loan)
		@subject += I18n.t 'loans.email.not approved'
		mail :to => loan.borrower.email, :subject => @subject
	end

	protected
	def setup_email(loan)
		@subject	= "#{I18n.t 'loans.email.prefix', site_name_short: site_name(short: true)} "
		@sent_on	= Time.now

		@owner		= loan.owner.login
		@borrower	= loan.borrower.login

		@item		= I18n.t('loans.email.body.item',
                                    :title => loan.item.title,
                                    :author_first => loan.item.author_first,
                                    :author_last => loan.item.author_last)

		# FIXME: don't hardcode urls, blah blah blah
		@item_url	= polymorphic_url(loan.item)
	end
end

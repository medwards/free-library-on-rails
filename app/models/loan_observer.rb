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

class LoanObserver < ActiveRecord::Observer
	include SMSFu if AppConfig.use_sms
	def after_create(loan)
		if loan.status == I18n.t('loans.status.requested') and loan.borrower != loan.item.owner
			LoanMailer.request_notification(loan).deliver
			if AppConfig.use_sms and loan.item.owner.cellphone?
				begin
					deliver_sms(loan.item.owner.cellphone,
loan.item.owner.cellphone_provider, I18n.t('loans.sms.request message', site_name: site_name))
				rescue Net::SMTPFatalError
					# don't freak out if this fails
				end
			end
		end
	end

	def after_lent(loan)
		if loan.borrower != loan.item.owner
			LoanMailer.approved_notification(loan).deliver
		end
	end

	def after_rejected(loan)
		LoanMailer.rejected_notification(loan).deliver
	end
end

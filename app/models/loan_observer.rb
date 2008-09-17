class LoanObserver < ActiveRecord::Observer
	include SMSFu
	def after_create(loan)
		if loan.status == 'Requested'
			LoanNotifier.deliver_request_notification(loan)
			if loan.item.owner.cellphone?
				deliver_sms(loan.item.owner.cellphone, loan.item.owner.cellphone_provider, "You have a loan request on the Edmonton Free Library")
			end
		end
	end

	def after_lent(loan)
		LoanNotifier.deliver_approved_notification(loan)
	end

	def before_destroy(loan)
		LoanNotifier.deliver_rejected_notification(loan)
	end
end

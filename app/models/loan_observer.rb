class LoanObserver < ActiveRecord::Observer
	def after_create(loan)
		if loan.status == 'Requested'
			LoanNotifier.deliver_request_notification(loan)
		end
	end

	def after_lent(loan)
		LoanNotifier.deliver_approved_notification(loan)
	end

	def before_destroy(loan)
		LoanNotifier.deliver_rejected_notification(loan)
	end
end

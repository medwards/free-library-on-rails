class LoanObserver < ActiveRecord::Observer
  def after_create(loan)
    LoanNotifier.deliver_request_notification(loan)
  end

  def after_lent(loan)
    LoanNotifier.deliver_approved_notification(loan)
  end

  def before_destroy(loan)
    LoanNotifier.deliver_rejected_notification(loan)
  end
end

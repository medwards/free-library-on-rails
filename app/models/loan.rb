class Loan < ActiveRecord::Base
  belongs_to :item
  belongs_to :borrower, :class_name => 'User'

  def approved?
    ['approved', 'lent', 'returned'].member? self.status
  end

  def approved!
    self.status = 'approved'
    save!
  end
end

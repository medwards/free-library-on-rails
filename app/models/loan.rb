# the 'status' field holds a string that is one of:
#   - requested
#   - approved
#   - lent
#   - returned
#   - rejected
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

  # make a new loan request
  def self.create_request(user, item)
    self.create(:borrower => user, :item => item, :status => 'requested')
  end

  # does this user already have an outstanding loan for this item?
  def self.already_requested(user, item)
    self.exists? ["borrower_id = ? AND item_id = ?" \
      " AND status NOT IN ('returned', 'rejected')", user, item]
  end
end

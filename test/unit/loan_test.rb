require File.dirname(__FILE__) + '/../test_helper'

class LoanTest < Test::Unit::TestCase
  def test_approved
    loan = loans(:request)

    assert !loan.approved?

    loan.approved!

    assert loan.approved?
  end

  def test_request
    pierre = users(:pierre)
    sg = items(:sg)

    loan = Loan.create_request(pierre, sg)
    assert_equal 'requested', loan.status
  end
end

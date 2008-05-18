require File.dirname(__FILE__) + '/../test_helper'

class LoanTest < Test::Unit::TestCase
  def test_approved
    loan = loans(:request)

    assert !loan.approved?

    loan.approved!

    assert loan.approved?
  end
end

require 'test_helper'

class LoanTest < ActiveSupport::TestCase
  def test_lent
    loan = loans(:request)

    assert !loan.approved?

    return_date = Date.today + 2.weeks

    loan.lent!(return_date)

    assert_equal 'lent', loan.status
    assert_equal return_date, loan.return_date
    assert_equal loan, loan.item.current_loan

    assert loan.approved?
  end

  def test_rejected
    loan = loans(:request)

    assert !loan.rejected?

    loan.rejected!

    assert_equal 'rejected', loan.status
    assert_nil loan.item.current_loan

    assert loan.rejected?
  end

  def test_request
    pierre = users(:pierre)
    sg = items(:sg)

    loan = Loan.create_request(pierre, sg)
    assert_equal 'requested', loan.status
  end

  def test_already_requested
    htc = items(:htc)
    lhd = items(:lhd)
    bct = users(:bct)
    pierre = users(:pierre)

    assert Loan.already_requested(bct, lhd)
    assert Loan.already_requested(pierre, htc)
    assert !Loan.already_requested(bct, htc)
  end


  def test_returned
    loan = loans(:loan)

    loan.returned!

    assert_equal 'returned', loan.status
    assert_nil loan.item.current_loan
  end
end

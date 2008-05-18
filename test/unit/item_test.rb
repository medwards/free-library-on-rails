require File.dirname(__FILE__) + '/../test_helper'

class ItemTest < Test::Unit::TestCase
  def test_owner
    lhd = items(:lhd)
    medwards = users(:medwards)

    assert_equal medwards, lhd.owner
  end

  def test_tagging
    htc = items(:htc)

    tags = htc.taggings.map { |t| t.to_s }.sort

    assert_equal ['politics', 'spain'], tags

    # tags can be added
    htc.tag_with ['nonfiction']

    assert_equal 3, htc.taggings.length

    # items can be found by tag
    tagged_with = Item.find_by_tag('nonfiction')

    assert_equal 1, tagged_with.length
    assert_equal htc, tagged_with[0]
  end

  def test_current_loan
    lhd = items(:lhd)
    bct = users(:bct)

    assert lhd.loaned?
    assert_equal bct, lhd.borrower
  end

  def test_return_item
    lhd = items(:lhd)

    lhd.returned!

    assert !lhd.loaned?
    assert_nil lhd.borrower

    assert Loan.find(:all, :conditions => {:item_id => lhd, :status => 'lent'}).empty?
  end
end

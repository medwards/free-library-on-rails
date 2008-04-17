require File.dirname(__FILE__) + '/../test_helper'

class ItemTest < Test::Unit::TestCase
  fixtures :items
  fixtures :users

  def test_owner
    lhd = Item.find(1)
    medwards = User.find_by_login('medwards')

    assert_equal medwards, lhd.owner
  end

  def test_holder
    lhd = Item.find(1)
    bct = User.find_by_login('bct')

    assert_equal bct, lhd.held_by
  end
end

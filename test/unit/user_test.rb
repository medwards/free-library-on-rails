require File.dirname(__FILE__) + '/../test_helper'

class UserTest < Test::Unit::TestCase
  fixtures :items
  fixtures :users

  def test_held
    lhd = Item.find(1)
    bct = User.find_by_login('bct')

    assert bct.held.member?(lhd)
  end

  def test_owned
    lhd = Item.find(1)
    medwards = User.find_by_login('medwards')

    assert medwards.owned.member?(lhd)
  end
end

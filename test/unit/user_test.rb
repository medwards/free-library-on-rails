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

  def test_distance
    bct      = User.find_by_login('bct')
    medwards = User.find_by_login('medwards')
    pierre   = User.find_by_login('pierre')

    assert_in_delta 2.47, bct.distance_from(medwards), 0.15
    assert_in_delta 2.47, medwards.distance_from(bct), 0.15

    assert_in_delta 2975, bct.distance_from(pierre), 5
    assert_in_delta 2975, pierre.distance_from(bct), 5
  end
end

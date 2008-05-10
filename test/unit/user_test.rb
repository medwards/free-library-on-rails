require File.dirname(__FILE__) + '/../test_helper'

class UserTest < Test::Unit::TestCase
  def setup
    @bct      = User.find_by_login('bct')
    @medwards = User.find_by_login('medwards')
    @pierre   = User.find_by_login('pierre')
  end


  def test_held
    lhd = Item.find(1)

    assert @bct.held.member?(lhd)
  end

  def test_owned
    lhd = Item.find(1)

    assert @medwards.owned.member?(lhd)
  end

  def test_distance
    assert_in_delta 2.47, @bct.distance_from(@medwards), 0.15
    assert_in_delta 2.47, @medwards.distance_from(@bct), 0.15

    assert_in_delta 2975, @bct.distance_from(@pierre), 5
    assert_in_delta 2975, @pierre.distance_from(@bct), 5
  end

  def test_region
    edmonton = Region.find_by_name('Edmonton')
    montreal = Region.find_by_name('Montréal')

    assert_equal edmonton, @bct.region
    assert_equal edmonton, @medwards.region
    assert_equal montreal, @pierre.region
  end
end

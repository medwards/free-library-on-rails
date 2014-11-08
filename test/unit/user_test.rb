# encoding: UTF-8
require 'test_helper'

class UserTest < ActiveSupport::TestCase
  def setup
    @bct      = User.find_by_login('bct')
    @medwards = User.find_by_login('medwards')
    @pierre   = User.find_by_login('pierre')
  end

  def test_authenticate
    assert_equal @bct, User.authenticate('bct', 'secret')
    assert_nil User.authenticate('bct', 'this-is-a-wrong-password')
    assert_equal @bct, User.authenticate('fake@example.org', 'secret')
  end

  def test_owned
    lhd = items(:lhd)

    assert @medwards.owned.member?(lhd)
  end

  def test_distance
    assert_in_delta 2.47, @bct.distance_from(@medwards), 0.15
    assert_in_delta 2.47, @medwards.distance_from(@bct), 0.15

    assert_in_delta 2975, @bct.distance_from(@pierre), 5
    assert_in_delta 2975, @pierre.distance_from(@bct), 5
  end

	def test_find_local
		near = @bct.nearbys(3)
		assert_equal [@medwards], near

		far = @bct.nearbys(3000)
		assert_equal [@medwards, @pierre], far
	end

  def test_region
    edmonton = Region.find_by_name('Edmonton')
    montreal = Region.find_by_name('Montréal')

    assert_equal edmonton, @bct.region
    assert_equal edmonton, @medwards.region
    assert_equal montreal, @pierre.region
  end

  def test_borrowed
    lhd = items(:lhd)

    assert_equal 1, @bct.borrowed.length
    assert_equal lhd, @bct.borrowed.first

    assert_equal 0, @pierre.borrowed.length
  end

  def test_borrowed_and_pending
    assert_equal 1, @bct.borrowed_and_pending.length
    assert_equal 1, @medwards.borrowed_and_pending.length
    assert_equal 2, @pierre.borrowed_and_pending.length
  end

  def test_lent_and_pending
    assert_equal 2, @medwards.lent_and_pending.length
    assert_equal 2, @bct.lent_and_pending.length
  end

  def test_tag_counts
    assert_equal([ ['politics', 2], ['spain', 1 ] ], @bct.tag_counts.to_a)
    assert_equal([ ], @medwards.tag_counts.to_a)
  end

  def test_tagging
	  bct = users(:bct)

	  tags = bct.tags.map(&:to_s).sort

	  assert_equal ['engineering', 'science'], tags

	  # tags can be added
	  bct.tag_with ['decentralization']

	  # users can be found by tag
	  tagged_with = User.find_by_tag('decentralization')

	  assert_equal 1, tagged_with.length
	  assert_equal bct, tagged_with[0]
  end
end

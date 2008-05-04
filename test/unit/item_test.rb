require File.dirname(__FILE__) + '/../test_helper'

class ItemTest < Test::Unit::TestCase
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

  def test_tagging
    htc = Item.find(2)

    assert_equal 2, htc.item_taggings.length

    tags = htc.item_taggings.map { |t| t.to_s }.sort

    assert_equal ['politics', 'spain'], tags

    users = htc.item_taggings.map { |t| t.user }
    bct = User.find_by_login('bct')

    assert(users.all? { |u| u == bct })
  end
end

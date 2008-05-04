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
end

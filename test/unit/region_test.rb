require File.dirname(__FILE__) + '/../test_helper'

class RegionTest < Test::Unit::TestCase
  def test_find_region_items
    edm = Region.find_by_subdomain('edmonton')

    lhd = Item.find_by_id(1)
    htc = Item.find_by_id(2)
    sg  = Item.find_by_id(3)

    assert_equal [lhd, htc, sg], edm.items.sort_by { |i| i.id }

    books = edm.items.find(:all, :conditions => {:type => 'Book'}).sort_by { |i| i.id }
    assert_equal [lhd, htc], books
  end
end

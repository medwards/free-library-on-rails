require 'test_helper'

class RegionTest < ActiveSupport::TestCase
  def test_find_region_items
    edm = Region.find_by_subdomain('edmonton')

    lhd = items(:lhd)
    htc = items(:htc)
    sg  = items(:sg)

    items = edm.items.sort_by { |i| i.id }

    [lhd, htc, sg].each do |i|
      assert items.member?(i)
    end

    books = edm.items.find(:all, :conditions => {:type => 'Book'})

    assert  books.member?(lhd)
    assert  books.member?(htc)
    assert !books.member?(sg)
  end
end

require File.dirname(__FILE__) + '/../test_helper'

class ItemTest < ActiveSupport::TestCase
	def test_owner
		lhd = items(:lhd)
		medwards = users(:medwards)

		assert_equal medwards, lhd.owner
	end

	def test_basic_tagging
		htc = items(:htc)

		tags = htc.tags.sort
		assert_equal ['politics', 'spain'], tags

		# an item's tags can be replaced
		htc.tag_with ['nonfiction']

		tags = htc.tags(true) # 'true' means refresh the cache
		assert_equal ['nonfiction'], tags

		# items can be found by tag
		tagged_with = Item.find_by_tag('nonfiction')

		assert_equal 1, tagged_with.length
		assert_equal htc, tagged_with[0]
	end

	def test_bad_tagging
		htc = items(:htc)

		# duplicate tags only get stored once
		htc.tag_with ['xyz', 'xyz', 'zyx']
		assert_equal ['xyz', 'zyx'], htc.tags(true).sort

		# can't tag an item with blacklisted tags
		AppConfig.TAG_BLACKLIST = ['x', 'y', 'xyzzy']

		htc.tag_with [ 'a', 'x', 'b', 'why', 'xyzzy', 'z']
		assert_equal [ 'a', 'b', 'why', 'z' ], htc.tags(true).sort

		# can't tag an item with blank tags
		htc.tag_with [ '', 'and so on.', ]
		assert_equal ['and so on.'], htc.tags(true).sort
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

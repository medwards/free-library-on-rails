require File.dirname(__FILE__) + '/../test_helper'

class BookTest < Test::Unit::TestCase
  def test_new_from_isbn
    shne = Book.new_from_isbn('0-385-66004-9')

    assert_equal '0385660049', shne.isbn
    assert_equal 'A Short History of Nearly Everything', shne.title
    assert_equal 'Bryson', shne.author_last
    assert_equal 'Bill', shne.author_first
  end
end

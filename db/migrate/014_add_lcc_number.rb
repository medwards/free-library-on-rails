# adds the Library of Congress Classification Nmuber field and fetches values from ISBNDB
# only does one query per second to be gentle on our generous benefactor
class AddLccNumber < ActiveRecord::Migration
  def self.up
	add_column :items, :lcc_number, :string

	Book.find(:all).each do |book|
		next unless book.isbn
		next if book.lcc_number

		sleep 1 # don't overload the server

		puts book.isbn
		xml = Book.get_isbndb_data(book.isbn, [:details])

		details = xml.elements['//Details[1]']
		next unless details # the book wasn't found at all?

		lcc_num = details.attributes['lcc_number']
		puts lcc_num
		next if lcc_num.empty? # no lcc number was fonud

		book.lcc_number = lcc_num
		book.save!
	end
  end

  def self.down
	remove_column :items, :lcc_number
  end
end

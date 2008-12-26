# Copyright 2009 Michael Edwards, Brendan Taylor
# This file is part of free-library-on-rails.
# 
# free-library-on-rails is free software: you can redistribute it
# and/or modify it under the terms of the GNU Affero General Public
# License as published by the Free Software Foundation, either
# version 3 of the License, or (at your option) any later version.

# free-library-on-rails is distributed in the hope that it will be
# useful, but WITHOUT ANY WARRANTY; without even the implied
# warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
# See the GNU Affero General Public License for more details.
# 
# You should have received a copy of the GNU Affero General Public
# License along with free-library-on-rails.
# If not, see <http://www.gnu.org/licenses/>.

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

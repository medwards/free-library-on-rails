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

class NoSuchISBN < RuntimeError; end

class Book < Item
	COVER_IMG_DIR = 'public/images/items/books/'

	def has_cover_image?
		self.isbn and not self.isbn.empty? and File.exists? self.cover_filename
	end

	def cover_filename
		COVER_IMG_DIR + self.isbn + '.jpg' if self.isbn
	end

	def fetch_cover_image
		GoogleBooksClient.new(self.isbn).save_cover_image(self.cover_filename) if self.isbn
	end

	def self.new_from_isbn(isbn)
		isbn = Isbn.new(isbn) unless isbn.is_a? Isbn
		isbndb_data = IsbnDbClient.new(isbn).get_data
		google_data = GoogleBooksClient.new(isbn).get_data

		if not isbndb_data and not google_data
			raise NoSuchISBN
		end

		isbndb_data ||= {}
		google_data ||= {}

		data = isbndb_data.merge(google_data)

		book = Book.new
		book.isbn         = data[:isbn]
		book.title        = data[:title]
		book.description  = data[:description]
		book.author_first = data[:author_first]
		book.author_last  = data[:author_last]
		book.tag_with(data[:tags])

		book
	end
end

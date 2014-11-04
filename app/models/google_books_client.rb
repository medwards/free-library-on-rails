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

require 'open-uri'

class GoogleBooksClient
	def initialize(isbn)
		@isbn = isbn
	end

	# a URL for an HTML representation of our desired book
	#
	# documented here: https://developers.google.com/books/docs/static-links
	def isbn_url
		'http://books.google.com/books?vid=ISBN' + @isbn
	end

	# turn our ISBN url into a canonical URL (including a google books ID
	# that we can use to do an API request)
	#
	# e.g. "http://books.google.ca/books/about/Red_Plenty.html?id=M75AAAAACAAJ"
	def canonical_url
		@canonical_url ||=	begin
								doc = Nokogiri::XML(open(self.isbn_url, 'User-Agent' => 'FLORa'))
								canonical_link = doc.at_xpath("//link[@rel='canonical']")
								canonical_link.attribute("href").to_s
							rescue URI::InvalidURIError, OpenURI::HTTPError
								nil
							end
	end

	# e.g. "M75AAAAACAAJ"
	def book_id
		return nil unless canonical_url
		canonical_url.split("id=").last
	end

	def volume_url
		return nil unless book_id
		"https://www.googleapis.com/books/v1/volumes/" + self.book_id
	end

	def get_data
		doc = fetch_json
		return nil unless doc

		doc = doc["volumeInfo"]

		data = {
			:isbn			=> @isbn,
			:title			=> doc["title"],
			:description	=> doc["description"],
			:cover_url		=>(doc["imageLinks"]["thumbnail"] rescue nil),
			:tags			=> doc["categories"]
		}

		author = doc["authors"].first
		if author
			data[:author_first], data[:author_last] = author.split(" ", 2)
		end

		data
	end

	# attempts to fetch a cover image for this book from Google Books. saves it
	# as the given filename.
	#
	# returns the original URL of the image or nil
	def save_cover_image(filename)
		if self.cover_image_url
			# download and save the image
			open(filename, "wb").write(open(self.cover_image_url).read)
		end
	end

	def cover_image_url
		json = fetch_json
		return nil unless json
		json['volumeInfo']['imageLinks']['thumbnail'] rescue nil
	end

protected

	def fetch_json
		return nil unless self.volume_url
		JSON.parse(open(self.volume_url).read)
	end
end

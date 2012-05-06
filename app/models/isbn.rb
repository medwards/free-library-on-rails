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

class Isbn
	def initialize(isbn)
		# CLEAN the ISBN... they can be a fucking mess even when copied properly
		isbn.gsub!(/[^0-9Xx]/, '')
		@isbn = isbn
	end

	def to_s;   @isbn; end
	def to_str; @isbn; end

	def valid?
		if ean?
			@isbn[12] == Isbn.ean_checksum(@isbn)
		elsif isbn10?
			@isbn[9] == Isbn.isbn_checksum(@isbn)
		else
			false
		end
	end

	def isbn10?
		@isbn.length == 10
	end

	def ean?
		@isbn.length == 13
	end

	# courtesy of http://www.ddj.com/web-development/184415967
	def self.isbn_checksum isbn
		sum = 0
		10.step( 2, -1 ) {
			|n|
			m = 10 - n
			sum += n * isbn[m..m].to_i
		}
		checksum = ( 11 - ( sum % 11 ) ) % 11
		checksum = 'X' if checksum == 10
		return checksum.to_s
	end

	def self.ean_checksum ean
		sum = 0
		0.step( 10, 2 ) { |n|
			sum += ean[n..n].to_i
			sum += ean[n+1..n+1].to_i * 3
		}
		return "#{ ( 10 * ( ( sum / 10 ) + 1 ) - sum ) % 10 }"
	end

end

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

class BooksController < ItemsController
	def itemclass; Book end

	def create
		if params[:submit] == 'Lookup'
			self.isbnLookup params[:item][:isbn]
		else
			super
		end
	end

	def isbnLookup isbn
		# CLEAN the ISBN... they can be a fucking mess even when copied properly
		isbn.gsub!(/[^0-9Xx]/, '')
		if(isbn.length == 13)
			if isbn[12..12] == BooksController.ean_checksum(isbn)
				isbn = isbn[3..-1]
				isbn[9] = BooksController.isbn_checksum(isbn).to_s
			else
				flash[:error] = "Lookup failed - Invalid EAN/Barcode"
				redirect_to :action => "new", :item => { :isbn => isbn }
				return
            end
		else
			if isbn[9] == BooksController.isbn_checksum(isbn)
				flash[:error] = "Lookup failed - Invalid ISBN"
				redirect_to :action => "new", :item => { :isbn => isbn }
				return
            end
        end

		begin
			@item = Book.new_from_isbn(isbn)
		rescue NoSuchISBN
			flash[:error] = "Lookup failed - could not find that ISBN."
			redirect_to :action => "new", :item => { :isbn => isbn }
			return
		end

		flash[:notice] = "Lookup successful."
		redirect_to :action => "new",
			:item => {
				:title =>        @item.title,
				:description =>	 @item.description,
				:isbn =>         @item.isbn,
				:lcc_number =>	 @item.lcc_number,
				:author_last =>	 @item.author_last,
				:author_first => @item.author_first
			},
			:tags => @item.tags
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

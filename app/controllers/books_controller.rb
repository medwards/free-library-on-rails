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
		if params[:lookup_isbn]
			new
			begin
				isbn = find_isbn(@item.isbn)
				@item = Book.new_from_isbn(isbn)
				flash[:notice] = I18n.t 'books.isbn lookup.message.success'
			rescue NoSuchISBN
				flash[:error] = I18n.t 'books.isbn lookup.message.isbn not found'
			end
			render 'new'
		else
			super
			@item.fetch_cover_image if AppConfig.fetch_covers
		end
	end

	protected

	def find_isbn(isbn)
		isbn = Isbn.new(isbn)

		unless isbn.valid?
			if isbn.ean?
				flash[:error] = I18n.t 'books.isbn lookup.message.invalid ean_barcode'
			else
				flash[:error] = I18n.t 'books.isbn lookup.message.invalid isbn'
			end
		end

		isbn
	end
end

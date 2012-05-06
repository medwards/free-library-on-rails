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

require 'rexml/document'

class IsbnDbClient
	ISBNDB_ROOT = 'http://isbndb.com/api/books.xml?access_key=' + AppConfig.ISBNDB_KEY

	def initialize(isbn)
		@isbn = isbn
	end

	def get_data
		xml = self.fetch_xml
		bookdata = xml.elements['//BookData[1]']
		return nil unless bookdata

		data = {
			:isbn			=> bookdata.attributes['isbn'],
			:title			=> bookdata.elements['Title'].text,
			:description	=> bookdata.elements['Summary'].text
		}

		# I think this just gets the first Person --bct
		author = bookdata.elements['Authors/Person']
		if author
			data[:author_last], data[:author_first] = author.text.split(', ', 2)
		end

		data[:tags] = bookdata.elements.to_a('Subjects/Subject').map do |subject|
			subject.text.to_s.split(' -- ')
		end.flatten

		details = xml.elements['//Details[1]']
		data[:lcc_number] = details.attributes['lcc_number']

		data
	end

protected
	def fetch_xml(results = [:subjects, :texts, :authors, :details])
		rstr = results.map { |r| '&results=' + r.to_s }.join
		url = ISBNDB_ROOT + rstr + '&index1=isbn&value1=' + @isbn

		REXML::Document.new(open(url))
	rescue URI::InvalidURIError, OpenURI::HTTPError
		nil
	end
end

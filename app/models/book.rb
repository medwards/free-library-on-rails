require 'open-uri'
require 'rexml/document'

require 'hpricot'

class NoSuchISBN < Exception; end

class Book < Item
		ISBNDB_KEY = 'PJ6X926W'
		ISBNDB_ROOT = 'http://isbndb.com/api/books.xml?access_key=' + ISBNDB_KEY

		def cover_filename
			'public/images/items/books/' + self.isbn + '.jpg'
		end

		def self.new_from_isbn(isbn)
			# spin off threads that will do metadata lookups on multiple services?
			threads = []

			isbndb_book = nil, google_book = nil

			isbndb_book = self.new_from_isbndb(isbn)
			google_book = self.new_from_google_books(isbn)

			book = isbndb_book
			if(book.isbn != nil and book.isbn != google_book.isbn)
				File.rename(google_book.cover_filename, book.cover_filename)
			end

			book.isbn ||= google_book.isbn
			book.title ||= google_book.title
			book.description ||= google_book.description
			book.author_first ||= google_book.author_first
			book.author_last ||= google_book.author_last
			book.tag_with(google_book.tags)

			book
		end

	def self.new_from_isbndb(isbn)
		book = self.new

		url = ISBNDB_ROOT + '&results=subjects&results=texts&results=authors&index1=isbn&value1=' + isbn

		begin
			xml = REXML::Document.new(open(url))
		rescue URI::InvalidURIError, OpenURI::HTTPError
			raise NoSuchISBN
		end

		bookdata = xml.elements['//BookData[1]']

		raise NoSuchISBN unless bookdata

		book.isbn = bookdata.attributes['isbn']

		book.title = bookdata.elements['Title'].text
		book.description = bookdata.elements['Summary'].text

		# I think this just gets the first Person --bct
		author = bookdata.elements['Authors/Person']
		if author
				book.author_last, book.author_first = author.text.split(', ', 2)
		end

		bookdata.elements.to_a('Subjects/Subject').each { |subject| book.tag_with subject.text.to_s.gsub(' -- ', ', ')}

		book
	end

	# as of 2008-08-02, this doesn't work. google seems to block based on User-Agent.
	def self.new_from_google_books(isbn)
		book = self.new

		book.isbn = isbn

		begin
			doc = Hpricot(open('http://books.google.com/books?vid=ISBN' << isbn, 'User-Agent' => 'FLORa'))
		rescue URI::InvalidURIError, OpenURI::HTTPError
			raise NoSuchISBN
		end

		book.title = doc.at("//h2[@class='title']").inner_text

		book.author_last = doc.at("//span[@class='addmd']").inner_html[3..-1]
		#authorblock = doc.at("//span[@class='addmd']").inner_html.split(", ")
		#book.author_last = authorblock[0][3..-1]
		#book.author_first = authorblock[1]

		image = doc.at("//img[@class='Preview this book']")
		image ||= doc.at("//img[@title='Front Cover']")

		if image
			open(book.cover_filename, "wb").write(open(image.attributes['src']).read)
		end

		synopsis = doc.at("//div[@id='synopsistext']")

		if synopsis
			review = synopsis.inner_text
		end

		review ||= doc.search("//div[@class='snippet']").sort_by { |x| x.inner_html.size }[0].inner_text
		book.description = review

		book.tag_with doc.at("//div[@class='bookinfo_sectionwrap']").inner_text

		book
	end
end

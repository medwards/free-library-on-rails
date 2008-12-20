require 'open-uri'
require 'rexml/document'

require 'hpricot'

class NoSuchISBN < Exception; end

class Book < Item
	ISBNDB_ROOT = 'http://isbndb.com/api/books.xml?access_key=' + AppConfig.ISBNDB_KEY
	COVER_IMG_DIR = 'public/images/items/books/'

	def has_cover_image?
		self.isbn and File.exists? self.cover_filename
	end

	def cover_filename
		COVER_IMG_DIR + self.isbn + '.jpg'
	end

	def self.new_from_isbn(isbn)
		# spin off threads that will do metadata lookups on multiple services?
		threads = []

		isbndb_book = nil, google_book = nil

		isbndb_book = self.new_from_isbndb(isbn)
		google_book = self.new_from_google_books(isbn)

		if !(isbndb_book or google_book)
			raise NoSuchISBN
		end

		isbndb_book ||= self.new

		book = isbndb_book
		if google_book != nil
			if(book.isbn != nil and book.isbn != google_book.isbn and File.exists?(google_book.cover_filename))
				File.rename(google_book.cover_filename, book.cover_filename)
			end

			book.isbn ||= google_book.isbn
			book.title ||= google_book.title
			book.description ||= google_book.description
			book.author_first ||= google_book.author_first
			book.author_last ||= google_book.author_last
			book.tag_with(google_book.tags)
		end

		book
	end

	def self.get_isbndb_data(isbn, results = [:subjects, :texts, :authors, :details])
		rstr = results.map { |r| '&results=' + r.to_s }.join
		url = ISBNDB_ROOT + rstr + '&index1=isbn&value1=' + isbn

		begin
			REXML::Document.new(open(url))
		rescue URI::InvalidURIError, OpenURI::HTTPError
			nil
		end
	end

	def self.new_from_isbndb(isbn)
		book = self.new

		xml = self.get_isbndb_data(isbn)

		bookdata = xml.elements['//BookData[1]']

		return nil unless bookdata

		book.isbn = bookdata.attributes['isbn']

		book.title = bookdata.elements['Title'].text
		book.description = bookdata.elements['Summary'].text

		# I think this just gets the first Person --bct
		author = bookdata.elements['Authors/Person']
		if author
			book.author_last, book.author_first = author.text.split(', ', 2)
		end

		bookdata.elements.to_a('Subjects/Subject').each { |subject| book.tag_with subject.text.to_s.gsub(' -- ', ', ')}

		details = xml.elements['//Details[1]']
		book.lcc_number = details.attributes['lcc_number']

		book
	end

	# fetches the google books page for an ISBN and parses it
	# returns nil on an error
	def self.get_google_books_page(isbn)
		begin
			url = 'http://books.google.com/books?vid=ISBN' << isbn
			Hpricot(open(url, 'User-Agent' => 'FLORa'))
		rescue URI::InvalidURIError, OpenURI::HTTPError
			nil
		end
	end

	# attempts to fetch a cover image for this book from Google Books. saves it
	# to COVER_IMG_DIR.
	#
	# 'doc' is a parsed (Hpricot) version of the book's Google Books page,
	# it will be fetched if not passed in.
	#
	# returns the original URL of the image or nil
	def fetch_cover_image(doc = nil)
		unless doc
			return unless self.isbn
			doc = Book.get_google_books_page(self.isbn)

			# couldn't find the page, just return without error.
			return unless doc
		end

		image = doc.at("//img[@title='Preview this book']")
		image ||= doc.at("//img[@title='Front Cover']")
		image ||= doc.at("//img[@title='Title Page']")

		if image
			url = image.attributes['src']

			# download and save the image
			open(self.cover_filename, "wb").write(open(url).read)

			url
		end
	end

	def self.new_from_google_books(isbn)
		book = self.new

		book.isbn = isbn

		doc = self.get_google_books_page(isbn)
		return nil unless doc

		title = doc.at("//h2[@class='title']")
		if title
			book.title = title.inner_text
		end

		authorblock = doc.at("//span[@class='addmd']")
		if authorblock
			authorblock = authorblock.inner_html.split(", ")
			authorblock = authorblock[0].reverse.split(' ', 2)
			book.author_last = authorblock[0].reverse
			book.author_first = authorblock[1].reverse[3..-1]
		end

		book.fetch_cover_image

		synopsis = doc.at("//div[@id='synopsistext']")

		if synopsis
			# some of these have got some weird characters
			synopsis = synopsis.inner_text.gsub("\xa0", '') # remove nonbreaking spaces
			book.description = synopsis.strip
		end

		keywords_div = doc.search("div[@id='keywords']")
		if keywords_div
			keywords = keywords_div.at("td")
			if keywords
				book.tag_with keywords.inner_text
			end
		end

		book
	end
end

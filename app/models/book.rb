require 'open-uri'
require 'rexml/document'

require 'hpricot'

class NoSuchISBN < Exception; end

class Book < Item
    ISBNDB_KEY = 'PJ6X926W'
    ISBNDB_ROOT = 'http://isbndb.com/api/books.xml?access_key=' + ISBNDB_KEY

    def self.new_from_isbn(isbn)
	# spin off threads that will do metadata lookups on multiple services?
	threads = []

	isbndb_book = nil, google_book = nil
	
	threads << Thread.new { isbndb_book = self.new_from_isbndb(isbn) }
	threads << Thread.new { google_book = self.new_from_google_books(isbn) }
	
	threads.each { |aThread|  aThread.join }
	book = isbndb_book
	if(book.isbn != nil and book.isbn != google_book.isbn)
	    File.rename('public/images/items/books/' + google_book.isbn + '.jpg', 'public/images/items/books/' + book.isbn + '.jpg')
        end
	book.isbn ||= google_book.isbn
	book.title ||= google_book.title
	book.description ||= google_book.description
	book.author_first ||= google_book.author_first
	book.author_last ||= google_book.author_last
	book.tag_with(google_book.tags)
    end

    def self.new_from_isbndb(isbn)
	book = self.new
	url = ISBNDB_ROOT + '&results=subjects&results=texts&results=authors&index1=isbn&value1=' + isbn

	xml = REXML::Document.new(open(url))

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
	doc = Hpricot(open('http://books.google.com/books?vid=ISBN' << isbn, 'User-Agent' => 'FLORa'))

	book.title = doc.at("//h2[@class='title']").inner_text

	book.author_last = doc.at("//span[@class='addmd']").inner_html[3..-1]
	#authorblock = doc.at("//span[@class='addmd']").inner_html.split(", ")
	#book.author_last = authorblock[0][3..-1]
	#book.author_first = authorblock[1]

	image = doc.at("//img[@class='Preview this book']")
	image ||= doc.at("//img[@title='Front Cover']")
	open("public/images/items/books/" << isbn << ".jpg", "wb").write(open(image.attributes['src']).read)

	review = doc.at("//div[@id='synopsistext']").inner_text
	review ||= doc.search("//div[@class='snippet']").sort_by { |x| x.inner_html.size }[0].inner_text
	book.description = review

	book.tag_with doc.at("//div[@class='bookinfo_sectionwrap']").inner_text
	
	return book
    end
end

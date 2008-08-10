require 'open-uri'
require 'rexml/document'

require 'hpricot'

class NoSuchISBN < Exception; end

class Book < Item
  ISBNDB_KEY = 'PJ6X926W'
  ISBNDB_ROOT = 'http://isbndb.com/api/books.xml?access_key=' + ISBNDB_KEY

  def self.new_from_isbn(isbn)
    # spin off threads that will do metadata lookups on multiple services?
    self.new_from_isbndb(isbn)
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

    bookdata.elements.to_a('Subjects/Subject').each { |subject| book.tag_with subject.text.to_s.gsub(' -- ', ', '); puts book.tags }

    book
  end

  # as of 2008-08-02, this doesn't work. google seems to block based on User-Agent.
  def self.new_from_google_books(isbn)
    book = self.new
    book.isbn = isbn

    doc = Hpricot(open('http://books.google.com/books?vid=ISBN' << isbn, 'User-Agent' => 'FLORa'))

    book.title = doc.at("//h2[@class='title']").inner_html

    book.author_last = doc.at("//span[@class='addmd']").inner_html[3..-1]
    #authorblock = doc.at("//span[@class='addmd']").inner_html.split(", ")
    #book.author_last = authorblock[0][3..-1]
    #book.author_first = authorblock[1]

    image = doc.at("//img[@title='Preview this book']")
    image &&= image.attributes['src']

    review = doc.at("//div[@id='synopsistext']")
    review ||= doc.search("//div[@class='snippet']").sort_by { |x| x.inner_html.size }[0].inner_html
    book.description = review

    #possible_tags = doc.at("//table[@id='bibdata']").search("a")[1].inner_html.split('/')

    #if !doc.search("//td[@class='volumetab '").empty?
    #  doc = Hpricot(open('http://books.google.com/books?vid=ISBN' << isbn << '&printsec=frontcover'))
    #  doc.at("//div[@id='subjects_v']").search("a").each { |l| p possible_tags = possible_tags << l.inner_html[0..-13].split(' / ')}
    #end

    #possible_tags.flatten.each {|l| l.downcase!}.uniq

    book
  end
end

require 'open-uri'
require 'hpricot'

class Book < Item
  def self.new_from_isbn(isbn)
    book = self.new
    book.isbn = isbn

    # spin off threads that will do metadata lookups on multiple services?
    # First google books
    doc = Hpricot(open('http://books.google.com/books?vid=ISBN' << isbn))

    book.title = doc.at("//h2[@class='title']").inner_html

    authorblock = doc.at("//span[@class='addmd']").inner_html.split(',  ')
    book.author_last = authorblock[0][3..-1]
    book.author_first = authorblock[1]

    image = doc.at("//img[@title='Preview this book']")
    image &&= image.attributes['src']

    review = doc.at("//div[@id='synopsistext']")
    review ||= doc.search("//div[@class='snippet']").sort_by { |x| x.inner_html.size }[0].inner_html
    book.description = review

    possible_tags = doc.at("//table[@id='bibdata']").search("a")[1].inner_html.split('/')

    #if !doc.search("//td[@class='volumetab '").empty?
    #  doc = Hpricot(open('http://books.google.com/books?vid=ISBN' << isbn << '&printsec=frontcover'))
    #  doc.at("//div[@id='subjects_v']").search("a").each { |l| p possible_tags = possible_tags << l.inner_html[0..-13].split(' / ')}
    #end

    possible_tags.flatten.each {|l| l.downcase!}.uniq

    book
  end
end

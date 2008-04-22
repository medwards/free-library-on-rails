require 'open-uri'
require 'hpricot'

class BooksController < ItemsController
  def itemclass; Book end

  def isbnLookup isbn
    # CLEAN the ISBN... they can be a fucking mess even when copied properly
    
    # spin off threads that will do metadata lookups on multiple services?
    # First google books
    doc = Hpricot(open('http://books.google.com/books?vid=ISBN' << isbn))
    title = doc.at("//h2[@class='title']").inner_html
    authorblock = doc.at("//span[@class='addmd']").split(',  ')
    author_last = authorblock[0][3..-1]
    author_first = authorblock[1]
    review = doc.at("//div[@id='synopsistext']")
    image = doc.at("//img[@title='Preview this book']")
    if image != nil
      image = image.attributes['src']
    end
    
    if review == nil
      review = doc.search("//div[@class='snippet']").sort { |x,y| x.inner_html.size <=> y.inner_html.size}[0]
    
    possible_tags = doc.at("//table[@id='bibdata']").search("a")[1].inner_html.split('/')
    if !doc.search("//td[@class='volumetab '").empty?
      doc = Hpricot(open('http://books.google.com/books?vid=ISBN' << isbn << '&printsec=frontcover'))
      doc.at("//div[@id='subjects_v']").search("a").each { |l| p possible_tags = possible_tags << l.inner_html[0..-13].split(' / ')}
    end
    possible_tags.flatten.each {|l| l.downcase!}.uniq
end

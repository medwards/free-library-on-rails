require 'open-uri'
require 'hpricot'

class BooksController < ItemsController
  def itemclass; Book end

  def create
    if params.key?(:lookup) && params[:lookup] == 'lookup'
      self.isbnLookup(params[:isbn])
    else
      super.create(params)
    end
  end
  
  def isbnLookup
    # CLEAN the ISBN... they can be a fucking mess even when copied properly
    isbn = params[:id]
    # begin cleanISBN; rescue invalidIsbnError flash; redirect; end
    
    # spin off threads that will do metadata lookups on multiple services?
    # First google books
    begin
      doc = Hpricot(open('http://books.google.com/books?vid=ISBN' << isbn))
    rescue OpenURI::HTTPError
      flash[:warning] = "Lookup failed - Could not find that ISBN"
      redirect_to :action => "new", :isbn => isbn
    end
    
    title = doc.at("//h2[@class='title']").inner_html
    authorblock = doc.at("//span[@class='addmd']").inner_html.split(',  ')
    author_last = authorblock[0][3..-1]
    author_first = authorblock[1]
    review = doc.at("//div[@id='synopsistext']")
    image = doc.at("//img[@title='Preview this book']")
    if image != nil
      image = image.attributes['src']
    end
    
    if review == nil
      review = doc.search("//div[@class='snippet']").sort { |x,y| x.inner_html.size <=> y.inner_html.size}[0]
    end
    
    possible_tags = doc.at("//table[@id='bibdata']").search("a")[1].inner_html.split('/')
    #if !doc.search("//td[@class='volumetab '").empty?
    #  doc = Hpricot(open('http://books.google.com/books?vid=ISBN' << isbn << '&printsec=frontcover'))
    #  doc.at("//div[@id='subjects_v']").search("a").each { |l| p possible_tags = possible_tags << l.inner_html[0..-13].split(' / ')}
    #end
    possible_tags.flatten.each {|l| l.downcase!}.uniq
    
    @item = itemclass.new
    @item.title = title
    @item.description = review
    @item.isbn = isbn
    @item.author_last = author_last
    @item.author_first = author_first
    
    flash[:notice] = "Lookup Successful"
    redirect_to :action => "new", :title => title, :description => review, :isbn => isbn, :author_last => author_last, :author_first => author_first
  end
end

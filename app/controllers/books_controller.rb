class BooksController < ItemsController
  def itemclass; Book end

  def create
    if params.key?(:lookup) && params[:lookup] == 'lookup'
      self.isbnLookup(params[:isbn])
    else
      super
    end
  end

  def isbnLookup
    # CLEAN the ISBN... they can be a fucking mess even when copied properly
    isbn = params[:id]
    # begin cleanISBN; rescue invalidIsbnError flash; redirect; end

    begin
      @item = Book.new_from_isbn(isbn)
    rescue OpenURI::HTTPError
      flash[:warning] = "Lookup failed - Could not find that ISBN"
      redirect_to :action => "new", :isbn => isbn
    end

    flash[:notice] = "Lookup Successful"
    redirect_to :action =>        "new",
                :title =>         @item.title,
                :description =>   @item.review,
                :isbn =>          @item.isbn,
                :author_last =>   @item.author_last,
                :author_first =>  @item.author_first
  end
end

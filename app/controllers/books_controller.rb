class BooksController < ItemsController
  def itemclass; Book end

  def create
    if params[:submit] == 'Lookup'
      self.isbnLookup params[:item][:isbn]
    else
      super
    end
  end

  def isbnLookup isbn
    # CLEAN the ISBN... they can be a fucking mess even when copied properly
		isbn.gsub!(/[^0-9Xx]/, '')

    begin
      @item = Book.new_from_isbn(isbn)
    rescue NoSuchISBN
      flash[:error] = "Lookup failed - could not find that ISBN."
      redirect_to :action => "new", :item => { :isbn => isbn }
      return
    end

    flash[:notice] = "Lookup successful."
    redirect_to :action =>        "new",
                :item => {
                  :title =>         @item.title,
                  :description =>   @item.description,
                  :isbn =>          @item.isbn,
                  :author_last =>   @item.author_last,
                  :author_first =>  @item.author_first
                },
                :tags =>          @item.tags
  end
end

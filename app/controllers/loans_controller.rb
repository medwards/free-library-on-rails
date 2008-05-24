class LoansController < ItemsController
  before_filter :login_required

  def new
    @item = Item.find(params[:item_id])
  end

  def create
    @item = Item.find(params[:item_id])

    Loan.create_request(self.current_user, @item)

    redirect_to polymorphic_path(@item)
  end
end

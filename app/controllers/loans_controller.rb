class LoansController < ApplicationController
  before_filter :login_required

  def index
    @borrowed_and_pending = self.current_user.borrowed_and_pending
    @lent_and_pending = self.current_user.lent_and_pending
  end

  def new
    @item = Item.find(params[:item_id])
  end

  def create
    @item = Item.find(params[:item_id])

    Loan.create_request(self.current_user, @item)

    flash[:notice] = "Loan request sent."

    redirect_to polymorphic_path(@item)
  end

  def destroy
    @loan = Loan.find(params[:id])

    unless @loan.borrower == self.current_user
      unauthorized "can't delete somebody else's loan request"; return
    end

    unless @loan.status == 'requested'
      unauthorized "can only cancel a pending request"; return
    end

    @loan.destroy

    redirect_to :action => 'index'
  end
end

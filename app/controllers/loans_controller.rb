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

		@loan = Loan.create_request(self.current_user, @item)

		if @item.owner == self.current_user and params[:return_date]
			return_date = Date.parse(params[:return_date])
			memo = params[:memo]

			@loan.lent!(return_date, memo)
		else
			flash[:notice] = "Loan request sent."
		end

		redirect_to polymorphic_path(@item)
	end

	def update
		@loan = Loan.find(params[:id])

		if @loan.status == "requested"
			unless @loan.item.owner == self.current_user
				unauthorized "you don't have permission to approve this loan"; return
			end

			if @loan.item.loaned?
				flash[:error] = "Can't loan an item that is already loaned."
			else
				return_date = Date.parse(params[:return_date])
				memo = params[:memo]

				@loan.lent!(return_date, memo)
				flash[:notice] = "Request approved."
			end
		elsif @loan.status == "lent"
			unless @loan.item.owner == self.current_user
				unauthorized "you don't have permission to mark this item as returned"; return
			end

			@loan.returned!
			flash[:notice] = "Return acknowledged."
		end

		redirect_back_or_to polymorphic_path(@loan.item)
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

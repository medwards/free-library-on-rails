# Copyright 2009 Michael Edwards, Brendan Taylor
# This file is part of free-library-on-rails.
#
# free-library-on-rails is free software: you can redistribute it
# and/or modify it under the terms of the GNU Affero General Public
# License as published by the Free Software Foundation, either
# version 3 of the License, or (at your option) any later version.

# free-library-on-rails is distributed in the hope that it will be
# useful, but WITHOUT ANY WARRANTY; without even the implied
# warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
# See the GNU Affero General Public License for more details.
#
# You should have received a copy of the GNU Affero General Public
# License along with free-library-on-rails.
# If not, see <http://www.gnu.org/licenses/>.

class LoansController < ApplicationController
	before_filter :login_required

	def index
		@title = I18n.t 'loans.index.title'
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
			flash[:notice] = I18n.t 'loans.create.message.request sent'
		end

		redirect_to polymorphic_path(@item)
	end

	def update
		@loan = Loan.find(params[:id])

		unless @loan.item.owner == self.current_user
			unauthorized I18n.t('loans.update.message.unauthorized'); return
		end

		if @loan.status == I18n.t('loans.status.requested')
			update_requested
		elsif @loan.status == I18n.t('loans.status.lent')
			update_lent
		end

		redirect_back_or_to polymorphic_path(@loan.item)
	end

	def destroy
		@loan = Loan.find(params[:id])

		unless @loan.borrower == self.current_user
			unauthorized I18n.t('loans.destroy.message.unauthorized delete'); return
		end

		unless @loan.status == I18n.t('loans.status.requested')
			unauthorized I18n.t('loans.destroy.message.unauthorized cancel'); return
		end

		@loan.destroy

		redirect_to :action => 'index'
	end

	private
	def update_requested
		if params[:status] == I18n.t('loans.status.rejected')
			@loan.rejected!
		elsif @loan.item.loaned?
			flash[:error] = I18n.t 'loans.update requested.message.already loaned'
		else
			if params[:return_date].empty?
				flash[:error] = I18n.t 'loans.update requested.message.date missing'
				return
			end

			begin
				return_date = Date.parse(params[:return_date])
			rescue ArgumentError
				flash[:error] = I18n.t 'loans.update requested.message.invalid date'
				return
			end

			if return_date <= Date.today
				flash[:error] = I18n.t 'loans.update requested.message.past date'
				return
			end

			memo = params[:memo]

			@loan.lent!(return_date, memo)
			flash[:notice] = I18n.t 'loans.update requested.message.approved'
		end
	end

	def update_lent
		@loan.returned!
		flash[:notice] = I18n.t 'loans.update lent.message.returned'
	end
end

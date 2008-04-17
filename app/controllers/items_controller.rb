class ItemsController < ApplicationController
  def show
    @item = Item.find(params[:id])
  end

  def new
    @item = Item.new
  end

  def create
    # XXX better unauth handling
    raise 'not logged in' unless logged_in?

    @item = Item.new(params[:item])

    @item.created = Time.now
    @item.owner = self.current_user
    @item.held_by = self.current_user

    @item.save!

    redirect_to item_path(@item.id)
  end
end

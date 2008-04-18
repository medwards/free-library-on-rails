class ItemsController < ApplicationController
  def show
    @item = Item.find(params[:id])
  end

  def new
    @item = Item.factory('')
  end

  def create
    # XXX better unauth handling
    raise 'not logged in' unless logged_in?

    @item = Item.factory('', params[:item])

    @item.created = Time.now
    @item.owner = self.current_user
    @item.held_by = self.current_user

    @item.save!

    redirect_to item_path(@item.id)
  end

  def destroy
    raise 'not logged in' unless logged_in?
    @item = Item.find(params[:id])
    raise 'not authorized to edit this item' unless self.current_user.id == @item.owner_id
    @item.destroy
    # XXX this has behaved weird anecdotally... come back to it and test
    redirect_to :action => "new"
  end
end

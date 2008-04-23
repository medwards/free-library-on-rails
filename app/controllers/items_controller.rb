class ItemsController < ApplicationController
  before_filter :login_required, :only => [ :new, :create, :destroy ]

  def itemclass; Item end

  def show
    @item = itemclass.find(params[:id])
  end

  def new
    if(params[:isbn] == nil)
      @item = itemclass.new
    else
      params.delete(:action)
      params.delete(:controller)
      @item = itemclass.new(params)
    end
  end

  def create
    @item = itemclass.new(params[:item])

    @item.created = Time.now
    @item.owner = self.current_user
    @item.held_by = self.current_user

    @item.save!

    redirect_to :controller => itemclass.to_s.tableize, :action => 'show', :id => @item
  end

  def destroy
    @item = Item.find(params[:id])
    raise 'not authorized to edit this item' unless self.current_user.id == @item.owner_id
    @item.destroy

    # XXX this has behaved weird anecdotally... come back to it and test
    redirect_to :action => "new"
  end
end

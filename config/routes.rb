ActionController::Routing::Routes.draw do |map|
  # See how all your routes lay out with "rake routes"

  # The priority is based upon order of creation: first created -> highest priority.

  map.resources :items, :collection => { :search => :get }
  map.resources :books, :collection => { :search => :get }
  map.resources :videos, :collection => { :search => :get }

  map.connect 'users/:id/search', :controller => 'users', :action => 'search'
  map.resources :users, :requirements => { :id => %r([^/;,?\.]+) }, :member => { :comments => :post }

  map.resources :loans

  map.resources :tags, :requirements => { :id => %r(.+) }

  # Sample resource route with options:
  #   map.resources :products, :member => { :short => :get, :toggle => :post }, :collection => { :sold => :get }

  # Sample resource route with sub-resources:
  #   map.resources :products, :has_many => [ :comments, :sales ], :has_one => :seller

  # Sample of named route:
  #   map.purchase 'products/:id/purchase', :controller => 'catalog', :action => 'purchase'
  # This route can be invoked with purchase_url(:id => product.id)

  # Sample resource route within a namespace:
  #   map.namespace :admin do |admin|
  #     # Directs /admin/products/* to Admin::ProductsController (app/controllers/admin/products_controller.rb)
  #     admin.resources :products
  #   end

  # Sample of regular route:
  #   map.connect 'products/:id', :controller => 'catalog', :action => 'view'
  # Keep in mind you can assign values other than :controller and :action

  # The Big GET /
  map.root :controller => 'welcome'
  map.connect 'about', :controller => 'welcome', :action => 'about'
  map.connect 'new', :controller => 'welcome', :action => 'new_things'

  # Install the default routes as the lowest priority.
  #   I try to avoid falling back on these -- bct
  map.connect ':controller/:action/:id'
  map.connect ':controller/:action/:id.:format'
end

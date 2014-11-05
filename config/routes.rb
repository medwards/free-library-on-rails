FreeLibraryOnRails::Application.routes.draw do
	# See how all your routes lay out with "rake routes"
	# The priority is based upon order of creation: first created -> highest priority.

	resources :items do
		collection { get :search }
	end

	resources :books do
		collection { get :search }
	end

	resources :videos do
		collection { get :search }
	end

	match 'users/:id/search' => 'users#search'
	resources :users, :constraints => { :id => %r([^/;,?\.]+) } do
		member do
			post :comments
		end
	end

	resources :loans
	resources :tags, :constraints => { :id => %r(.+) } do
		collection { get :autocomplete }
	end

	match 'about' => 'welcome#about'
	match 'new'   => 'welcome#new_things'

	get '/account/activate/:id' => 'account#activate', :as => :activate

	root :to => 'welcome#index'

	# Install the Rails 2 default routes as the lowest priority.
	#   I try to avoid falling back on these -- bct
	match '/:controller(/:action(/:id))'
end

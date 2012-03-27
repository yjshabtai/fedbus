FedbusRails32::Application.routes.draw do
  ActiveAdmin.routes(self)

  resources :notices

  resources :ticket_logs

  resources :roles

  resources :permissions

  resources :reading_weeks

  get 'tickets/find_user'
  get 'tickets/find_dests'
  get 'tickets/find_deps'
  get 'tickets/ticket_data'
  get 'tickets/update_price'
  get 'tickets/buy'
  get 'tickets/sell'
  get 'tickets/update_destinations'
  get 'tickets/update_ticket_data'
  post 'tickets/reserve'
  resources :tickets

  resources :users

  resources :invoices

  resources :holidays

  resources :buses

  resources :destinations

  resources :trips

  resources :blackouts
  
  resources :search

  # The priority is based upon order of creation:
  # first created -> highest priority.

  # Sample of regular route:
  #   match 'products/:id' => 'catalog#view'
  # Keep in mind you can assign values other than :controller and :action

  # Sample of named route:
  #   match 'products/:id/purchase' => 'catalog#purchase', :as => :purchase
  # This route can be invoked with purchase_url(:id => product.id)

  # Sample resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

  # Sample resource route with options:
  #   resources :products do
  #     member do
  #       get 'short'
  #       post 'toggle'
  #     end
  #
  #     collection do
  #       get 'sold'
  #     end
  #   end

  # Sample resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Sample resource route with more complex sub-resources
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get 'recent', :on => :collection
  #     end
  #   end

  # Sample resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end

  # You can have the root of your site routed with "root"
  # just remember to delete public/index.html.
  root :to => 'tickets#buy'

  # See how all your routes lay out with "rake routes"
  match 'login', :to => 'users#login', :as => "login"
  match 'logout', :to => 'users#logout', :as => "logout"
  match 'cart', :to => 'users#cart', :as => "cart"

  # This is a legacy wild controller route that's not recommended for RESTful applications.
  # Note: This route will make all actions in every controller accessible via GET requests.
  # match ':controller(/:action(/:id))(.:format)'
end

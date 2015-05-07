Rails.application.routes.draw do

  devise_for :admins
  devise_for :sellers 
  devise_for :users
  resources :listings do
    resources :orders
    member do
      put "like", to: "listings#like"
      put "bookmark", to: "listings#bookmark"
    end
    get 'page/:page', :action => :index, :on => :collection  # it is for SEO friendly.
  end

  mount StripeEvent::Engine, at: '/stripe_event_webhook'

  #resources :sellers do
  #  member do
  #    put "promote", to: "management#promote"
  #  end
  #end

  get 'pages/about'
  get 'pages/contact'

  #user
  get 'purchases' => "orders#purchases"
  get 'show_bookmark' => "listings#show_bookmark"
  get 'sort' => "listings#sort"
  get 'index_weighted' => 'listings#index_weighted'


  #seller
  get 'sales' => "orders#sales"
  get 'my_listings' => "listings#my_listings"
  get 'confirm_pickup' => 'orders#confirm_pickup'

  #admin
  get 'management/show_sellers' => 'management#show_sellers'
  get 'management/promote' => 'management#promote'

  # The priority is based upon order of creation: first created -> highest priority.
  # See how all your routes lay out with "rake routes".

  # You can have the root of your site routed with "root"
  # root 'welcome#index'
  root 'listings#index_weighted'
  # Example of regular route:
  #   get 'products/:id' => 'catalog#view'

  # Example of named route that can be invoked with purchase_url(id: product.id)
  #   get 'products/:id/purchase' => 'catalog#purchase', as: :purchase

  # Example resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

  # Example resource route with options:
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

  # Example resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Example resource route with more complex sub-resources:
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get 'recent', on: :collection
  #     end
  #   end

  # Example resource route with concerns:
  #   concern :toggleable do
  #     post 'toggle'
  #   end
  #   resources :posts, concerns: :toggleable
  #   resources :photos, concerns: :toggleable

  # Example resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end
end

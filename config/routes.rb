Rails.application.routes.draw do

  get '/auth/500px/callback' => 'sessions#create'
  get '/login' => 'sessions#login', as: 'login'
  get '/logout' => 'sessions#logout', as: 'logout'
  get '/unauthorized' => 'sessions#unauthorized'

  get '/faq' => 'pages#faq'

  get 'rankings/index'

  get 'home/index'
  post 'home/dismiss-onboarding' => 'home#dismiss_onboarding'

  get 'onboarding' => 'sessions#onboarding'

  # Join the current round
  post 'join' => 'sessions#join'

  resources :rounds, only: %i(index show) do
    get 'current', on: :collection
    get 'next', on: :collection
    resources :participants, only: %w(show)
    post 'withdraw'
    post 'join'
  end

  resources :players, except: %i(new create)

  resource :profile, only: %i(show edit update)

  resources :games, only: %i(show update)

  root 'home#index'

  # The priority is based upon order of creation: first created -> highest priority.
  # See how all your routes lay out with "rake routes".

  # You can have the root of your site routed with "root"
  # root 'welcome#index'

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

Rails.application.routes.draw do

  get '/auth/500px/callback' => 'sessions#create'
  get '/login' => 'sessions#login', as: 'login'
  get '/logout' => 'sessions#logout', as: 'logout'
  get '/unauthorized' => 'sessions#unauthorized'

  get '/faq' => 'pages#faq'

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
end

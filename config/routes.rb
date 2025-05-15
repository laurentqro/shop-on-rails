Rails.application.routes.draw do
  root "products#index"

  resources :products, only: [:index, :show]
  resource :session
  resources :passwords, param: :token

  get "up" => "rails/health#show", as: :rails_health_check
end
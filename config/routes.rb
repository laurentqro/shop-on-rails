Rails.application.routes.draw do
  root "products#index"

  resources :products, only: [:index, :show]
  resource :session
  resources :passwords, param: :token

  namespace :admin do
    get "/", to: "pages#index"
    resources :products
  end

  get "up" => "rails/health#show", as: :rails_health_check
end
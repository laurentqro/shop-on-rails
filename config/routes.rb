Rails.application.routes.draw do
  root "products#index"

  resources :products, only: [:index, :show], path: "product"
  resource :session
  resources :passwords, param: :token
  resource :registration, only: [:new, :create], path: "register", path_names: { new: "" }

  namespace :admin do
    get "/", to: "products#index"
    resources :products
  end

  get "up" => "rails/health#show", as: :rails_health_check
end

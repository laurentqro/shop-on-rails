Rails.application.routes.draw do
  root "products#index"

  resources :products, only: [ :index, :show ], path: "product"
  resource :session, path: "signin", path_names: { new: "" }
  resources :passwords, param: :token
  resource :registration, only: [ :new, :create ], path: "signup", path_names: { new: "" }

  resource :cart, only: [ :show, :destroy ] do
    resources :cart_items, only: [ :create, :update, :destroy ], path_names: { edit: "" }
  end

  resource :checkout, only: [ :show ]

  namespace :admin do
    get "/", to: "products#index"
    resources :products
  end

  get "up" => "rails/health#show", as: :rails_health_check
end

Rails.application.routes.draw do
  root "pages#home"

  get "shop", to: "pages#shop"
  get "branding", to: "pages#branding"
  get "samples", to: "pages#samples"
  get "about", to: "pages#about"
  get "contact", to: "pages#contact"
  get "terms", to: "pages#terms"
  get "privacy", to: "pages#privacy"
  get "cookies-policy", to: "pages#cookies_policy"

  resources :products, only: [ :index, :show ], path: "product"
  resource :session, path: "signin", path_names: { new: "" }
  resources :passwords, param: :token
  resource :registration, only: [ :new, :create ], path: "signup", path_names: { new: "" }

  resource :cart, only: [ :show, :destroy ] do
    resources :cart_items, only: [ :create, :update, :destroy ], path_names: { edit: "" }
  end

  resource :checkout, only: [ :show, :create ] do
    get :success, on: :collection
    get :cancel, on: :collection
  end

  resources :orders, only: [ :show, :index ]

  namespace :admin do
    get "/", to: "products#index"
    resources :products do
      get :new_variant, on: :member
    end
    resources :product_variants, only: [ :edit, :update ]
    resources :orders, only: [ :index, :show ]
  end

  # Product feeds
  get "feeds/google-merchant.xml", to: "feeds#google_merchant", as: :google_merchant_feed

  get "up" => "rails/health#show", as: :rails_health_check
end

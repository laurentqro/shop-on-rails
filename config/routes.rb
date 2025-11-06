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

  # FAQ page
  get "faqs", to: "faqs#index"

  resources :products, only: [ :index, :show ], path: "product"
  resources :categories, only: [ :show ], path: "category"

  # Branded products shortcut
  get "branded-products", to: "categories#show", defaults: { id: "branded-products" }
  resource :session, path: "signin", path_names: { new: "" }
  resources :passwords, param: :token
  resource :registration, only: [ :new, :create ], path: "signup", path_names: { new: "" }

  resources :email_address_verifications, only: [ :show, :create ], param: :token

  resource :cart, only: [ :show, :destroy ] do
    resources :cart_items, only: [ :create, :update, :destroy ], path_names: { edit: "" }
  end

  resource :checkout, only: [ :show, :create ] do
    get :success, on: :collection
    get :cancel, on: :collection
  end

  resources :orders, only: [ :show, :index ]

  namespace :branded_products do
    post "calculate_price", to: "configurator#calculate_price"
    get "available_options/:product_id", to: "configurator#available_options", as: :available_options
    get "compatible_lids", to: "lids#compatible_lids"
  end

  namespace :organizations do
    resources :products, only: [ :index, :show ]
  end

  namespace :admin do
    get "/", to: "products#index"
    resources :products do
      get :new_variant, on: :member
    end
    resources :product_variants, only: [ :edit, :update ]
    resources :categories
    resources :orders, only: [ :index, :show ]
    resources :branded_orders, only: [ :index, :show ] do
      member do
        patch :update_status
        post :create_instance_product
      end
    end
  end

  # Product feeds
  get "feeds/google-merchant.xml", to: "feeds#google_merchant", as: :google_merchant_feed
  get "sitemap.xml", to: "sitemaps#show", defaults: { format: :xml }, as: :sitemap
  get "robots.txt", to: "robots#show", defaults: { format: :text }

  get "up" => "rails/health#show", as: :rails_health_check
end

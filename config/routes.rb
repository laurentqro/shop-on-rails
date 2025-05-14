Rails.application.routes.draw do
  root "pages#about"
  get "up" => "rails/health#show", as: :rails_health_check
end

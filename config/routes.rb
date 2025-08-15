Rails.application.routes.draw do
  root to: redirect("/up")
  get "up" => "rails/health#show", as: :rails_health_check
  post "sign_in", to: "sessions#create"
  post "sign_up", to: "registrations#create"

  resources :sessions, only: [ :index, :show, :destroy ]
  resource :password, only: [ :edit, :update ]
  namespace :identity do
    resource :email, only: [ :edit, :update ]
    resource :email_verification, only: [ :show, :create ]
    resource :password_reset, only: [ :new, :edit, :create, :update ]
  end

  namespace :v1, format: :json do
    resources :countries, only: [ :index, :show ]
  end
end

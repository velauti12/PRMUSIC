Rails.application.routes.draw do
  get "up" => "rails/health#show", as: :rails_health_check


  namespace :api do
    namespace :v1 do
      post "login", to: "sessions#create"
      resources :songs
      resources :artists
      resources :genres
      resources :users
      resources :favorites
    end
  end

  namespace :admin do
    root "dashboard#index"
    resources :songs do
      member do
        patch :approve
        patch :reject
      end
    end
    resources :artists
    resources :genres
    resources :users
  end
end

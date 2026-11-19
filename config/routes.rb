Rails.application.routes.draw do
  # Bandeja de mails de prueba (solo en desarrollo)
  mount LetterOpenerWeb::Engine, at: "/letter_opener" if Rails.env.development?

  get "up" => "rails/health#show", as: :rails_health_check


  namespace :api do
    namespace :v1 do
      post "login", to: "sessions#create"
      delete "logout", to: "sessions#destroy"
      resources :songs do
        get :mine, on: :collection          # GET /api/v1/songs/mine
        get :transpose, on: :member         # GET /api/v1/songs/:id/transpose?semitones=N
      end
      resources :artists
      resources :genres
      resources :users
      resources :favorites, only: %i[index show create destroy]
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
    resources :albums, except: :show
    resources :genres
    resources :users, only: %i[index show]
  end
end

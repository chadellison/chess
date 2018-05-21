Rails.application.routes.draw do
  mount ActionCable.server => '/cable'

  namespace :api do
    namespace :v1, format: :json do
      resources :games, only: [:index]
    end
  end
end

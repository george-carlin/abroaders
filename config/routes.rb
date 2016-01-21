Rails.application.routes.draw do
  devise_for :users, skip: [:sessions, :registrations]

  namespace :admin do
    resources :cards, only: [:show, :index, :new, :create] do
      member do
        put :active
      end
    end
    resources :airports, only: :index
    resources :users do
      resources :card_accounts, as: :card_recommendations
    end
  end

  devise_scope :user do
    get    :sign_in, to: "devise/sessions#new",      as: :new_user_session
    post   :sign_in, to: "devise/sessions#create",   as: :user_session
    delete :sign_out, to: "devise/sessions#destroy", as: :destroy_user_session
    get :sign_up, to: "registrations#new"

    post :sign_up, to: "registrations#create", as: :user_registration
    get :sign_up,  to: "registrations#new", as: :new_user_registration

    get "users/cancel", to: "registrations#cancel", as: :cancel_user_registration

    # TODO this probably won't work with the default Devise views
    # post :users, to: "registrations#create", as: :user_registration
    put  :users, to: "registrations#update"
    delete :users, to: "registrations#destroy"
  end

  get  :survey, to: "user_infos#new"
  post :survey, to: "user_infos#create"

  get "survey/cards", to: "card_accounts#survey"

  resources :travel_plans

  namespace :api, defaults: { format: :json } do
    namespace :v1 do
      resources :airports
      resources :users
    end
  end

  root to: "application#root"
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html

  # Serve websocket cable requests in-process
  # mount ActionCable.server => '/cable'
end

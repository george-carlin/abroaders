Rails.application.routes.draw do
  devise_for :users, skip: [:sessions, :registrations]

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

  scope :survey, controller: :survey, as: :survey do
    get  :/, action: :user_info,        as: :user_info
    post :/, action: :create_user_info, as: nil

    get  :cards, action: :card_accounts, as: :card_accounts
    post :cards, action: :create_card_accounts, as: nil

    get  :balances
    post :balances, action: :create_balances
  end

  # Note that 'cards' is a fixed list, and 'card accounts' is the join table
  # between a user and a card. But the user doesn't care about anyone's cards
  # except his own, and from his perspective he doesn't have a "card account"
  # in the app, he just has a "card". So show the path 'cards' to the user even
  # though we're dealing with the CardAccount model, not the Card model.
  resources :card_accounts, path: :cards do
    member do
      post :open
      get  :apply
      post :decline
      post :deny
    end
  end

  resources :travel_plans

  namespace :admin do
    resources :cards, only: [:show, :index, :new, :create] do
      member do
        put :active
      end
    end
    resources :card_offers
    resources :destinations, only: :index

    Destination.types.keys.each do |type|
      # airports, cities, countries, etc
      get type.pluralize, to: "destinations##{type}"
    end

    resources :users do
      resources :card_accounts, as: :cards
      resources :card_recommendations, only: [:new, :create]
    end
  end

  namespace :api, defaults: { format: :json } do
    namespace :v1 do
      resources :airports
      resources :users
    end
  end

  root to: "application#root"

end

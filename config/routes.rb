Rails.application.routes.draw do
  devise_for :accounts, skip: [:sessions, :registrations]

  root to: "application#dashboard"

  match "/accounts/connect/awardwallet", to: "application#placeholder", via: %i[get post]

  devise_scope :account do
    get    :sign_in,  to: "sessions#new",     as: :new_account_session
    post   :sign_in,  to: "sessions#create",  as: :account_session
    delete :sign_out, to: "sessions#destroy", as: :destroy_account_session
    get :sign_up, to: "registrations#new"

    post :sign_up, to: "registrations#create", as: :account_registration
    get :sign_up,  to: "registrations#new", as: :new_account_registration

    get "accounts/cancel", to: "registrations#cancel", as: :cancel_account_registration

    # TODO this probably won't work with the default Devise views
    # post :accounts, to: "registrations#create", as: :account_registration
    put  :accounts, to: "registrations#update"
    delete :accounts, to: "registrations#destroy"
  end

  get :slack, to: "slack_invites#new"
  post "slack/invite", to: "slack_invites#create"

  get  "survey/travel_plan", to: "travel_plans#new"
  post "survey/travel_plan", to: "travel_plans#create"

  scope :survey, controller: :survey, as: :survey do

    get  :passengers, action: :new_passengers
    post :passengers, action: :create_passengers

    get  :spending, action: :new_spending
    post :spending, action: :create_spending

    passenger_constraints = { passenger: /(main)|(companion)/ }

    get  "cards/(:passenger)", action: :new_card_accounts,
          as: :card_accounts, constraints: passenger_constraints
    post "cards/:passenger",  action: :create_card_accounts,
          as: nil,            constraints: passenger_constraints

    get  "balances/(:passenger)", action: :new_balances,
          as: :balances, constraints: passenger_constraints
    post "balances/:passenger", action: :create_balances,
          as: nil,       constraints: passenger_constraints

    get  :ready, action: :new_readiness,    as: :readiness
    post :ready, action: :create_readiness, as: nil
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

  # ---- ADMINS -----

  devise_for :admins, skip: [:registrations, :sessions]
  devise_scope :admin do
    get    :"admin/sign_in",  to: "admin_area/sessions#new",
                                              as: :new_admin_session
    post   :"admin/sign_in",  to: "admin_area/sessions#create",
                                              as: :admin_session
    delete :"admin/sign_out", to: "devise/sessions#destroy",
                                              as: :destroy_admin_session
  end

  namespace :admin, module: :admin_area do
    resources :accounts, only: [ :index, :show ]
    resources :cards, only: %i[show index new create edit update]
    resources :card_offers, only: %i[show index new create edit update]
    resources :destinations, only: :index
    Destination.types.keys.each do |type|
      # airports, cities, countries, etc
      get type.pluralize, to: "destinations##{type}"
    end
    resources :passengers, only: :show do
      resources :card_recommendations, only: [:new, :create]
    end
  end

  # ---- /ADMINS -----

  namespace :api, defaults: { format: :json } do
    namespace :v1 do
      resources :accounts
      resources :destinations, only: [] do
        collection do
          get :typeahead
        end
      end
    end
  end

end

Rails.application.routes.draw do
  devise_for :accounts, skip: [:sessions, :registrations]

  devise_scope :account do
    get    :sign_in, to: "devise/sessions#new",      as: :new_account_session
    post   :sign_in, to: "devise/sessions#create",   as: :account_session
    delete :sign_out, to: "devise/sessions#destroy", as: :destroy_account_session
    get :sign_up, to: "registrations#new"

    post :sign_up, to: "registrations#create", as: :account_registration
    get :sign_up,  to: "registrations#new", as: :new_account_registration

    get "accounts/cancel", to: "registrations#cancel", as: :cancel_account_registration

    # TODO this probably won't work with the default Devise views
    # post :accounts, to: "registrations#create", as: :account_registration
    put  :accounts, to: "registrations#update"
    delete :accounts, to: "registrations#destroy"
  end

  scope :survey, controller: :survey, as: :survey do
    get  :passengers, action: :new_passengers
    post :passengers, action: :create_passengers

    get  :spending, action: :new_spending
    post :spending, action: :create_spending

    card_survey_page_constraints = { passenger: /(main)|(companion)/ }
    get  "cards/(:passenger)", action: :new_card_accounts,
          as: :card_accounts, constraints: card_survey_page_constraints
    post "cards/(:passenger)", action: :create_card_accounts,
          as: nil,            constraints: card_survey_page_constraints

    get  :balances, action: :new_balances
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

    resources :accounts do
      resources :card_accounts, as: :cards
      resources :card_recommendations, only: [:new, :create]
    end
  end

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

  root to: "application#root"

end

Rails.application.routes.draw do
  root to: "application#dashboard"
  # Even though we're overriding all the generated routes, we still need to
  # include the devise_for call to get access to methods like
  # `authenticate_account!`
  devise_for :account, only: []

  get "/accounts/connect/awardwallet", to: "oauth#award_wallet"

  get "/styles", to: "application#styles"

  devise_scope :account do
    get    :sign_in,  to: "sessions#new",     as: :new_account_session
    post   :sign_in,  to: "sessions#create",  as: :account_session
    delete :sign_out, to: "sessions#destroy", as: :destroy_account_session
    get :sign_up, to: "registrations#new"

    post :sign_up, to: "registrations#create", as: :account_registration
    get :sign_up,  to: "registrations#new", as: :new_account_registration

    get "accounts/cancel", to: "registrations#cancel", as: :cancel_account_registration

    post "accounts/password",     to: "passwords#create", as: :account_password
    get "accounts/password/new",  to: "passwords#new",    as: :new_account_password
    get "accounts/password/edit", to: "passwords#edit",   as: :edit_account_password
    put   "accounts/password",    to: "passwords#update"
    patch "accounts/password",    to: "passwords#update"

    # TODO this probably won't work with the default Devise views
    # post :accounts, to: "registrations#create", as: :account_registration
    put  :accounts, to: "registrations#update"
    delete :accounts, to: "registrations#destroy"
  end

  controller :static_pages do
    get :privacy_policy
    get :terms_and_conditions
  end

  resource :account, only: [] do
    get  :type
    post :solo,    action: :create_solo_account
    post :partner, action: :create_partner_account
  end

  get :slack, to: "slack_invites#new"
  post "slack/invite", to: "slack_invites#create"

  # Note that 'cards' is a fixed list, and 'card accounts' is the join table

  resources :people, only: [] do
    resource :readiness_status, path: :readiness

    resources :balances, only: [] do
      collection do
        get  :survey
        post :survey, action: :save_survey
      end
    end
    resources :card_accounts, path: :cards, only: [] do
      collection do
        get  :survey
        post :survey, action: :save_survey
      end
    end
    resource :spending_info, path: :spending, except: :new do
      get :survey, action: :new, as: :new
    end
  end

  resources :notifications, only: :show

  # Note that 'cards' is a fixed list, and 'card accounts' is the join table
  # between a user and a card. But the user doesn't care about anyone's cards
  # except his own, and from his perspective he doesn't have a "card account"
  # in the app, he just has a "card". So show the path 'cards' to the user even
  # though we're dealing with the CardAccount model, not the Card model.
  resources :card_accounts, path: :cards

  resources :card_recommendations do
    member do
      get   :apply
      patch :decline
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
    get :"admin/edit", to: "devise/registrations#edit",
                                              as: :edit_admin_registration
    put   :admin, to: "devise/registrations#update", as: :admin_registration
    patch :admin, to: "devise/registrations#update"
  end

  namespace :admin, module: :admin_area do
    resources :accounts, only: [ :index, :show ]
    resources :cards, only: [] do
      collection do
        get  :images
      end
    end
    resources :cards, except: :destroy do
      resources :offers, except: :destroy
    end
    # show and edit redirect to the nested action:
    resources :offers, only: [] do
      collection do
        get :review
        post :update_offers_last_reviewed_at
      end
    end
    # show and edit redirect to the nested action:
    resources :offers, only: [:show, :edit, :index] do
      member do
        patch :kill
      end
    end
    resources :destinations, only: :index
    Destination.types.keys.each do |type|
      # airports, cities, countries, etc
      get type.pluralize, to: "destinations##{type}"
    end
    resources :people, only: :show do
      resources :card_recommendations, only: [:new, :create] do
        collection do
          post :complete
        end
      end
    end
  end

  # ---- /ADMINS -----

end

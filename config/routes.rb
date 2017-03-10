require 'resque/server'

Rails.application.routes.draw do
  root to: "application#dashboard"
  # Even though we're overriding all the generated routes, we still need to
  # include the devise_for call to get access to methods like
  # `authenticate_account!`
  devise_for :account, only: []

  # Mount this at a hard-to-guess URL
  mount Resque::Server.new, at: "/resque-c08cb17ca6581cbcad1501a7da7e8579"

  get "/accounts/connect/awardwallet", to: "oauth#award_wallet"

  # --- NON-LOGGED-IN USERS ---

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
    put :accounts, to: "registrations#update"
    delete :accounts, to: "registrations#destroy"
  end

  # --- EVERYBODY ---

  controller :static_pages do
    get :privacy_policy
    get :terms_and_conditions
  end

  get "/styles", to: "application#styles"

  # --- LOGGED IN ACCOUNTS ---

  resource :account, only: [] do
    get  :type
    post :type, action: :submit_type
  end

  resources :airports, only: [:index]

  # balances#new and balances#create are nested under 'people'
  resources :balances, only: [:index, :update, :destroy]

  resources :card_recommendations do
    member do
      get   :apply
      patch :decline
    end
  end

  resources :cards

  get  "eligibility/survey", to: "eligibilities#survey", as: :survey_eligibility
  post "eligibility/survey", to: "eligibilities#save_survey"

  get "estimates/:from_code/:to_code/:type/:no_of_passengers", to: "estimates#get"

  namespace :integrations do
    get 'award_wallet/settings'
    namespace :award_wallet do
      get :callback
      get :poll

      resources :owners, only: [] do
        member do
          patch :update_person
        end
      end
    end
  end

  resources :interest_regions, only: [], path: "regions_of_interest" do
    collection do
      get  :survey
      post :survey, action: :save_survey
    end
  end

  resources :home_airports do
    collection do
      get  :edit
      post :overwrite
      get  :survey
      post :survey, action: :save_survey
    end
  end

  resources :notifications, only: :show

  resources :people, only: [] do
    resources :balances, only: [:new, :create] do
      collection do
        get  :survey
        post :survey, action: :save_survey
      end
    end
    resources :cards, only: [] do
      collection do
        get  :survey
        post :survey, action: :save_survey
      end
    end
    resource :spending_info, path: :spending, only: [:edit, :update]
  end

  resource :phone_number, only: [:new, :create] do
    post :skip
  end

  resources :products, only: [] do
    resources :cards, only: [:new, :create]
  end

  resource :readiness, only: [:edit, :update] do
    collection do
      get  :survey
      post :survey, action: :save_survey
    end
  end

  get :slack, to: "slack_invites#new"
  post "slack/invite", to: "slack_invites#create"

  resource :spending_info, path: :spending, only: [] do
    get :survey
    post :survey, action: :save_survey
  end

  resources :travel_plans do
    collection do
      patch :skip_survey
    end
  end

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
    resources :accounts, only: [:index, :show] do
      collection do
        get :search
      end
    end
    resources :banks, only: [:index, :edit, :update]
    resources :card_products, except: :destroy do
      collection do
        get :images
      end
      resources :offers, except: :destroy
    end

    resources :cards, only: [:edit, :update, :destroy]

    # show and edit redirect to the nested action:
    resources :offers, only: [:show, :edit, :index] do
      collection do
        get :review
      end
      member do
        patch :kill, :verify
      end
    end
    resources :destinations, only: :index
    Destination::TYPES.each do |type|
      # airports, cities, countries, etc
      get type.pluralize, to: "destinations##{type}"
    end
    resources :people, only: :show do
      resources :cards, only: [:new, :create]
      resource :spending_info
      resources :cards
      resources :card_recommendations, only: [:create] do
        collection do
          post :complete
          get  :pulled
        end
      end
    end
    resources :card_recommendations do
      member do
        patch :pull
      end
    end
    resources :travel_plans, only: [:edit, :update]
  end

  # ---- /ADMINS -----
end

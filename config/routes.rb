require 'resque/server'

Rails.application.routes.draw do
  get 'errors/not_found'
  get 'errors/internal_server_error'
  match "/404", to: "errors#not_found", via: :all
  match "/500", to: "errors#internal_server_error", via: :all

  root to: "application#dashboard"

  # Mount this at a hard-to-guess URL
  mount Resque::Server.new, at: "/resque-c08cb17ca6581cbcad1501a7da7e8579"

  # --- NON-LOGGED-IN USERS ---

  get :sign_up, to: "registrations#new"
  post :sign_up, to: "registrations#create", as: :account_registration
  get :sign_up,  to: "registrations#new", as: :new_account_registration

  get :sign_in, to: "sessions#new", as: :new_account_session
  post :sign_in, to: "sessions#create", as: :account_session
  delete :sign_out, to: "sessions#destroy", as: :destroy_account_session

  post 'accounts/password',     to: 'passwords#create', as: :account_password
  get 'accounts/password/new',  to: 'passwords#new',    as: :new_account_password
  get 'accounts/password/edit', to: 'passwords#edit',   as: :edit_account_password
  put   'accounts/password',    to: 'passwords#update'
  patch 'accounts/password',    to: 'passwords#update'

  # --- EVERYBODY ---

  resources :airports, only: [] do
    collection { get :typeahead }
  end

  Destination::TYPES.each do |type|
    # /airports, /cities, /countries, /regions
    get type.pluralize, to: "destinations##{type}"
  end

  controller :static_pages do
    get :privacy_policy
    get :terms_and_conditions
    get :contact_us
  end

  get "/styles", to: "application#styles"

  # --- LOGGED IN ACCOUNTS ---

  resource :account, only: [:edit, :update] do
    get  :type
    post :type, action: :submit_type
  end

  # balances#new and balances#create are nested under 'people'
  resources :balances, only: [:index, :edit, :update, :destroy]

  resources :card_recommendations do
    member do
      get   :click
      patch :decline
    end
  end

  resources :card_accounts, except: :index
  resources :cards, only: :index

  get  "eligibility/survey", to: "eligibilities#survey", as: :survey_eligibility
  post "eligibility/survey", to: "eligibilities#save_survey"

  get "estimates/:from_code/:to_code/:type/:no_of_passengers", to: "estimates#get"

  namespace :integrations do
    get 'award_wallet/settings'
    namespace :award_wallet do
      get :callback
      get :poll
      get :sync
      get :syncing

      resources :owners, only: [] do
        member do
          patch :update_person
        end
      end

      resources :accounts
    end
  end

  get 'auth/facebook/callback', to: 'integrations/facebook#callback'

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
    resource :spending_info, path: :spending, only: [:edit, :update] do
      member do
        patch :confirm
      end
    end
  end

  resource :phone_number, only: [:new, :create] do
    post :skip
  end

  resources :card_products, only: [] do
    resources :card_accounts, only: [:new, :create]
  end

  resource :readiness, only: [:edit, :update] do
    collection do
      get  :survey
      post :survey, action: :save_survey
    end
  end

  resource :recommendation_requests

  get :slack, to: "slack_invites#new"
  post "slack/invite", to: "slack_invites#create"

  resource :spending_info, path: :financials, only: [:show] do
    get :survey
    post :survey, action: :save_survey
  end

  resources :travel_plans do
    collection do
      patch :skip_survey
    end
  end

  # ---- ADMINS -----

  # This method is necessary to get the 'authenticate_admin!' method
  # in the controllers

  get 'admin/sign_in', to: 'admin_area/sessions#new', as: :new_admin_session
  post 'admin/sign_in', to: 'admin_area/sessions#create', as: :admin_session
  delete 'admin/sign_out', to: 'admin_area/sessions#destroy',
    as: :destroy_admin_session

  namespace :admin, module: :admin_area do
    resources :accounts, only: [:index] do
      collection do
        get :search
      end
      member do
        get :inspect
      end
    end
    resources :admins
    resources :banks, only: [:index]
    resources :card_products, except: :destroy do
      collection do
        get :images
      end
      resources :offers, only: [:index, :create, :new]
    end

    resources :card_accounts, only: [:edit, :update]
    resources :currencies

    # show and edit redirect to the nested action:
    resources :offers, only: [:show, :edit, :index, :update] do
      collection do
        get :review
      end
      member do
        patch :kill, :replace, :unkill, :verify
      end
    end
    resources :destinations, only: :index
    Destination::TYPES.each do |type|
      # /airports, /cities, /countries, /regions
      get type.pluralize, to: "destinations##{type}"
    end
    resources :people, only: :show do
      resource :spending_info
      resources :card_accounts
      resources :card_recommendations, only: [:create, :edit, :update] do
        collection do
          post :complete
        end
      end
    end
    resources :card_recommendations
    resources :recommendation_notes, only: [:edit, :update]
    resources :recommendation_requests
    resource :registration
    resources :travel_plans, only: [:edit, :update]
  end

  # ---- /ADMINS -----
end

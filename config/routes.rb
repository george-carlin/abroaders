Rails.application.routes.draw do
  devise_for :users, skip: [:sessions, :registrations]

  namespace :admin do
    resources :cards, only: [:show, :index, :new, :create]
    resources :airports, only: :index
    resources :users do
      resources :card_accounts
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

  resource :contact_info, except: :new
  get "add_contact_info", to: "contact_infos#new", as: :new_contact_info

  get  "spending", to: "spending_infos#new", as: :new_spending_info
  post "spending", to: "spending_infos#create", as: :spending_info

  namespace :api, defaults: { format: :json } do
    namespace :v1 do
      resources :users
    end
  end

  root to: "application#root"
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html

  # Serve websocket cable requests in-process
  # mount ActionCable.server => '/cable'
end

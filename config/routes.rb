Rails.application.routes.draw do
  devise_for :users, skip: [:sessions, :registrations]

  namespace :admin do
    resources :cards, only: [:show, :index, :new, :create]
    resources :users do
      resources :card_accounts
    end
  end

  devise_scope :user do
    get    :sign_in, to: "devise/sessions#new",      as: :new_user_session
    post   :sign_in, to: "devise/sessions#create",   as: :user_session
    delete :sign_out, to: "devise/sessions#destroy", as: :destroy_user_session
    get :sign_up, to: "devise/registrations#new"

    post :sign_up, to: "devise/registrations#create", as: :user_registration
    get :sign_up,  to: "devise/registrations#new", as: :new_user_registration

    get "users/cancel", to: "devise/registrations#cancel",
                        as: :cancel_user_registration

    # TODO this probably won't work with the default Devise views
    # post :users, to: "devise/registrations#create", as: :user_registration
    put  :users, to: "devise/registrations#update"
    delete :users, to: "devise/registrations#destroy"

  end

  root to: "application#root"
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html

  # Serve websocket cable requests in-process
  # mount ActionCable.server => '/cable'
end

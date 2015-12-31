Rails.application.routes.draw do
  devise_for :users, skip: :sessions

  namespace :admin do
    resources :cards
    resources :users do
      resources :card_accounts
    end
  end

  devise_scope :user do
    get    :sign_in, to: "devise/sessions#new",      as: :new_user_session
    post   :sign_in, to: "devise/sessions#create",   as: :user_session
    delete :sign_out, to: "devise/sessions#destroy", as: :destroy_user_session
    get :sign_up, to: "devise/registrations#new"
  end

  
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

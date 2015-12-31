Rails.application.routes.draw do
  devise_for :administrators
  devise_for :users

  devise_scope :user do
    get :sign_in, to: "devise/sessions#new"
    get :sign_up, to: "devise/registrations#new"
  end

  root to: "application#root"
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html

  # Serve websocket cable requests in-process
  # mount ActionCable.server => '/cable'
end

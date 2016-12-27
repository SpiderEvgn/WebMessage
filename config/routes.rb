Rails.application.routes.draw do

  get '/users/:access_token/contacts', to: 'contacts#index', as: 'user_contacts'

  devise_for :users
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  root 'dashboard#index'
end
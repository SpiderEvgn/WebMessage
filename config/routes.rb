Rails.application.routes.draw do

  get '/user/:access_token/contacts', to: 'contacts#index', as: 'user_contacts'
  post '/user/:access_token/contacts', to: 'contacts#create'
  get '/user/:access_token/contacts/new', to: 'contacts#new', as: 'user_new_contact'

  resources :contacts

  devise_for :users
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  root 'dashboard#index'
end
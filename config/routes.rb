Rails.application.routes.draw do

  get '/user/:access_token/contacts', to: 'contacts#index', as: 'user_contacts'
  post '/user/:access_token/contacts', to: 'contacts#create'
  get '/user/:access_token/contacts/new', to: 'contacts#new', as: 'user_new_contact'
  delete '/user/:access_token/contact/:id', to: 'contacts#destroy', as: 'user_contact'


  # get '/user/:access_token/contact/:to_user_id/messages', to: 'messages#index', as: 'user_contact_messages'

  resources :contacts

  devise_for :users
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  root 'contacts#index'
end
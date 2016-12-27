Rails.application.routes.draw do
  
  get 'messages/index'

  scope '/user/:access_token' do
    get '/contacts', to: 'contacts#index', as: 'user_contacts'
    post '/contacts', to: 'contacts#create'
    get '/contacts/new', to: 'contacts#new', as: 'user_new_contact'
    delete '/contact/:id', to: 'contacts#destroy', as: 'user_contact'

    scope '/contact/:to_user_id' do
      get '/messages', to: 'messages#index', as: 'user_contact_messages'
      post '/messages', to: 'messages#create'
    end
  end


  resources :contacts

  devise_for :users
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  root 'contacts#index'
end
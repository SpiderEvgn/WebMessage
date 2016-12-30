Rails.application.routes.draw do
    
  resources :contacts, only: [:index, :new, :create, :destroy] do
    resources :messages, only: [:index, :create, :destroy]
    get '/messages_history', to: 'messages#history', as: "messages_history"
  end

  devise_for :users
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  root 'contacts#index'

  match '*a', to: 'errors#routing', via: :all
end
Rails.application.routes.draw do
    
  resources :contacts, only: [:index, :create, :destroy] do
    resources :messages, only: [:index, :create, :update, :destroy]
    get '/messages_history', to: 'messages#history', as: "messages_history"
  end

  devise_for :users
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  root 'contacts#index'

  mount ActionCable.server => '/cable'

  match '*a', to: 'errors#routing', via: :all
end
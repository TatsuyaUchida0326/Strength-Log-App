Rails.application.routes.draw do
  get 'exercises/new'
  get 'exercises/create'
  root 'static_pages#top'
  get '/signup', to: 'users#new'

  # ログイン機能
  get    '/login', to: 'sessions#new'
  post   '/login', to: 'sessions#create'
  delete '/logout', to: 'sessions#destroy'

  resources :users

  # ここに新しいルートを追加
  resources :exercises, only: [:new, :create, :index, :destroy]
end

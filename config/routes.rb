Rails.application.routes.draw do
  root 'static_pages#top'
  get '/signup', to: 'users#new'

  # ログイン機能
  get    '/login', to: 'sessions#new'
  post   '/login', to: 'sessions#create'
  delete '/logout', to: 'sessions#destroy'

  resources :users

  resources :exercises, only: [:show, :new, :create, :index, :destroy, :edit, :update] do
    collection do
      get :strength_log
      post :add_existing
    end
  end
end
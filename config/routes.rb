Rails.application.routes.draw do
  root 'dashboard#index'
  devise_for :users

  namespace :admin do
    get 'dashboard', to: 'dashboard#index'
    get 'users', to: 'dashboard#users'
    resources :loans, only: [:index, :show] do
      member do
        post :approve
        post :reject
      end
      resources :loan_adjustments, only: [:new, :create]
    end
  end

  namespace :user do
    get 'dashboard', to: 'dashboard#index'
    resources :loans do
      member do
        post :accept_approval
        post :reject_approval
        post :request_readjustment
        post :repay
        post :respond_to_adjustment
      end
    end
  end

  require 'sidekiq/web'
  mount Sidekiq::Web => '/sidekiq'

end

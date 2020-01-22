require 'sidekiq/web'
Rails.application.routes.draw do
  authenticate :user, lambda { |u| u.admin? } do
    mount Sidekiq::Web => '/sidekiq'
  end

  use_doorkeeper
  devise_for :users
  root to: 'questions#index'

  concern :voteable do
    member do
      post :upvote
      post :downvote
      delete :cancel_vote
    end
  end

  concern :commentable do
    resources :comments, only: :create
  end

  resources :questions do
    concerns :voteable
    concerns :commentable
    resources :subscriptions, shallow: true, only: %i(create destroy)
    resources :answers, shallow: true do
      concerns :voteable
      concerns :commentable
      member { patch :mark_best }
    end
  end

  resources :files, only: :destroy
  resources :rewards, only: :index

  namespace :api do
    namespace :v1 do
      resources :profiles, only: :index do
        get :me, on: :collection
      end

      resources :questions, only: %i(index show create update destroy) do
        resources :answers, only: %i[index show create update destroy], shallow: true
      end
    end
  end

  mount ActionCable.server => '/cable'
end

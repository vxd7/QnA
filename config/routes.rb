Rails.application.routes.draw do
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
      resources :profiles, only: [] do
        get :me, on: :collection
      end

      resources :questions, only: :index
    end
  end

  mount ActionCable.server => '/cable'
end

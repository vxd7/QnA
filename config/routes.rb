Rails.application.routes.draw do
  devise_for :users
  root to: 'questions#index'

  concern :voteable do
    member do
      post :upvote
      post :downvote
      delete :cancel_vote
    end
  end

  resources :questions do
    concerns :voteable
    resources :answers, shallow: true do
      concerns :voteable
      member { patch :mark_best }
    end
  end

  resources :files, only: :destroy
  resources :rewards, only: :index

  mount ActionCable.server => '/cable'
end

Rails.application.routes.draw do
  devise_for :users, skip: :all
  devise_scope :user do
    namespace :api, format: false do
      namespace :v1 do
        resources :sessions, only: :create
        resources :crawls, except: [:new, :edit]
        resources :stops, except: [:new, :edit]
      end
    end
  end
end

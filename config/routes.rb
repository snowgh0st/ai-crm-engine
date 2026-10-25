# frozen_string_literal: true

Rails.application.routes.draw do
  root "dashboard#index"

  namespace :api do
    namespace :v1 do
      post 'search', to: 'search#create'
    end
  end

  resources :documents, only: [:create]
end
Rails.application.routes.draw do
  require 'sidekiq/web'

  get 'ui(/:action)', controller: 'ui'

  root                        to: 'pages#home'
  get '/home',                to: 'pages#home'
  get '/browse',              to: 'pages#browse'
  get '/tour',                to: 'pages#tour'
  get '/faq',                 to: 'pages#faq'
  get '/about',               to: 'pages#about'
  get '/contact',             to: 'pages#contact'
  get '/signout',             to: 'sessions#destroy'
  get "/signup",              to: 'users#new'

  resources :users,    only: [:create]
  resources :sessions, only: [:create]

  mount Sidekiq::Web, at: '/sidekiq'  #for online monitoring
end

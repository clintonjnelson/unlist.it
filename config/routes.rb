Rails.application.routes.draw do
  require 'sidekiq/web'

  get 'ui(/:action)', controller: 'ui'

  root                              to: 'pages#home'
  get '/home',                      to: 'pages#home'
  get '/browse',                    to: 'pages#browse'
  get '/tour',                      to: 'pages#tour'
  get '/faq',                       to: 'pages#faq'
  get '/about',                     to: 'pages#about'
  get '/contact',                   to: 'pages#contact'
  get '/invalid_address',           to: 'pages#invalid_address'
  get '/signout',                   to: 'sessions#destroy'
  get '/signup',                    to: 'users#new'
  get '/userconfirmation/:token',   to: 'users#confirm_with_token', as: 'userconfirmation'


  resources :users,    only: [:create]
  resources :sessions, only: [:create]

  mount Sidekiq::Web, at: '/sidekiq'  #for online monitoring
end

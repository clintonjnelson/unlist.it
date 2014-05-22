Rails.application.routes.draw do
  get 'ui(/:action)', controller: 'ui'

  root                        to: 'users#new'
  get 'home',                 to: 'pages#home'
  get '/browse',              to: 'pages#browse'
  get '/tour',                to: 'pages#tour'
  get '/faq',                 to: 'pages#faq'
  get '/about',               to: 'pages#about'
  get '/contact',             to: 'pages#contact'
  get '/signout',             to: 'sessions#destroy'

  resources :users,    only: [:new, :create]
  resources :sessions, only: [:new, :create]
end

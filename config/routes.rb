Rails.application.routes.draw do
  get 'ui(/:action)', controller: 'ui'

  root                        to: 'pages#home'
  get 'home',                 to: 'pages#home'
  get '/browse',              to: 'pages#browse'
  get '/tour',                to: 'pages#tour'
  get '/faq',                 to: 'pages#faq'
  get '/about',               to: 'pages#about'
  get '/contact',             to: 'pages#contact'


end

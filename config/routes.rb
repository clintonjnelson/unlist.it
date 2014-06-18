Rails.application.routes.draw do
  require 'sidekiq/web'

  get 'ui(/:action)', controller: 'ui'

  root                                  to: 'pages#home'
  get   '/home',                        to: 'pages#home'
  get   '/browse',                      to: 'pages#browse'
  get   '/browse/:category_id',         to: 'unposts#index_by_category', as: "browse_category"
  get   '/tour',                        to: 'pages#tour'
  get   '/faq',                         to: 'pages#faq'
  get   '/about',                       to: 'pages#about'
  get   '/contact',                     to: 'pages#contact'
  get   '/invalid_address',             to: 'pages#invalid_address'
  get   '/signout',                     to: 'sessions#destroy'
  get   '/signup',                      to: 'users#new'
  get   '/userconfirmation/:token',     to: 'users#confirm_with_token',  as: 'userconfirmation'
  get   '/forgot_password',             to: 'forgot_passwords#new'
  post  '/forgot_password',             to: 'forgot_passwords#create'
  get   '/expired_password_reset',      to: 'reset_passwords#expired_password_reset'

  #AJAX
  post '/conditions_by_category',     to: 'unposts#conditions_by_category'
  #post '/unposts_by_category',        to: 'pages#unposts_by_category'

  resources :reset_passwords,       only: [:create, :show]
  resources :sessions,              only: [:create]
  #Protects Users by anonymity. BUILD THIS OUT - ADD SLUGS TOO
  resources :unposts,               only: [:show, :index] do  #INDEX for general searching & use by non-creator
    collection do
      post  :search
    end
    resources :messages,            only: [:create, :index]
    get 'show_message_form',       to: 'unposts#show_message_form' #AJAX
  end
  resources :users,                 only: [:create, :show, :edit, :update] do
    resources :messages,            only: [:new, :create, :show, :index] #INDEX specific to user browsing own items
    resources :unposts,           except: [:index]
    get       '/unlist',              to: 'unposts#index'
  end


  namespace :admin do
    resources :categories
    resources :conditions,          only: [:new, :create, :edit, :update, :destroy]
    resources :users,               only: [:index, :destroy]
    post '/conditions_by_category',   to: 'conditions#conditions_by_category'
  end

  mount Sidekiq::Web,                 at: '/sidekiq'  #for online monitoring
end

Rails.application.routes.draw do
  require 'sidekiq/web'

  get 'ui(/:action)', controller: 'ui'

  root                                    to: 'pages#home'
  get     '/home',                        to: 'pages#home'
  get     '/browse',                      to: 'pages#browse'
  get     '/browse/:category_id',         to: 'unlistings#index_by_category', as: "browse_category"
  get     '/tour',                        to: 'pages#tour'
  get     '/faq',                         to: 'pages#faq'
  get     '/about',                       to: 'pages#about'
  get     '/contact',                     to: 'pages#contact'
  get     '/termsandconditions',          to: 'pages#termsandconditions'
  get     '/futurefeature',               to: 'pages#futurefeature'
  get     '/gettingstarted',              to: 'pages#gettingstarted'
  get     '/invalid_address',             to: 'pages#invalid_address'
  get     '/expired_link',                to: 'pages#expired_link'
  get     '/invite-registration/:token',  to: 'users#new_with_invite',     as: 'register_with_invite'
  get     '/invitation-sent',             to: 'pages#invitation_sent'
  get     '/safeguestsuccess',            to: 'pages#safeguestsuccess'
  get     '/signout',                     to: 'sessions#destroy'
  get     '/signup',                      to: 'users#new'
  get     '/userconfirmation/:token',     to: 'users#confirm_with_token',  as: 'userconfirmation'
  get     '/forgot_password',             to: 'forgot_passwords#new'
  post    '/forgot_password',             to: 'forgot_passwords#create'
  get     '/safeguestconfirmation/:token',to: 'safeguests#create',         as: 'safeguestconfirmation'
  post    '/add_unimage',                 to: 'unimages#create'
  delete  '/remove_unimage',              to: 'unimages#destroy'


  #AJAX
  post    '/conditions_by_category',      to: 'unlistings#conditions_by_category'
  post    '/show_thumbnails',             to: 'unlistings#show_thumbnails'
  patch   '/toggle_avatar',               to: 'users#toggle_avatar'
  get     '/search_location',             to: 'searches#search_location'
  post    '/search_location',             to: 'searches#set_search_location'
  get     '/search_radius',               to: 'searches#search_radius'
  get     '/remove_radius',               to: 'searches#remove_radius'
  post    '/search_radius',               to: 'searches#set_search_radius'


  resources :blogs,                     only: [:index]
  resources :reset_passwords,           only: [:create, :show]
  resources :sessions,                  only: [:create]

  resources :unlistings,                only: [:show, :index] do  #INDEX for general searching & use by non-creator
    collection do
      post      :search,                  to: 'searches#search'
    end
    resources :messages,                only: [:create, :index]
    get       'show_message_form',        to: 'unlistings#show_message_form' #AJAX
  end
  resources :users,                     only: [:create, :show, :edit, :update] do
    resources :invitations,             only: [:new, :create]
    resources :messages,                only: [:new, :create, :show, :index] #INDEX specific to user browsing own items
    get       '/feedback',                to: 'messages#new_feedback'
    resources :preferences,             only: [:update]
    resources :questionaires,           only: [:edit, :update]
    get       '/email_questionaire',      to: 'questionaires#questionaire_email'
    resources :unlistings,            except: [:index]
    get       '/unlist',                  to: 'unlistings#index'
    get       '/location_modal',          to: 'users#location_modal'
    post      '/update_location',         to: 'users#update_location'
  end


  namespace :admin do
    resources :blogs,                   only: [:new, :create, :edit, :update, :destroy]
    resources :categories
    resources :conditions,              only: [:new, :create, :edit, :update, :destroy]
    resources :settings,                only: [:edit, :update]
    resources :users,                   only: [:index, :destroy]
    post      '/conditions_by_category',  to: 'conditions#conditions_by_category'
  end

  mount Sidekiq::Web,                     at: '/sidekiq'  #for online monitoring
end

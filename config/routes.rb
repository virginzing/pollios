require 'sidekiq/web'
require 'api_constraints'

Pollios::Application.routes.draw do

  namespace :api, defaults: {format: 'json'} do
    scope module: :v1, constraints: ApiConstraints.new(version: 1, default: :true) do
      scope 'group/:group_id' do
        get 'polls',  to: 'companies#polls'
        get 'polls/:id/detail', to: 'companies#poll_detail'
      end
    end

    scope module: :v2, constraints: ApiConstraints.new(version: 2) do
      scope 'group/:group_id' do
        get 'polls',  to: 'companies#polls'
      end
    end
  end

  get "password_resets/new"
  devise_for :admins, :controllers => { :registrations => "admin/registrations" }

  mount RailsAdmin::Engine => '/admin', :as => 'rails_admin'

  resources :recurrings

  resources :campaigns

  resources :polls do
    resources :choices
  end
  resources :members 
  resources :poll_series
  resources :password_resets
  # resources :invites
  resources :companies

  get 'invites/new',    to: 'invites#new',  as: :new_invitation

  scope 'build_poll' do
    get 'binary',   to: 'polls#binary', as: :binary_poll
    get 'rating',   to: 'polls#rating', as: :rating_poll
    get 'freeform', to: 'polls#freeform', as: :freeform_poll
  end

  scope 'build_questionnaire' do
    get 'normal', to: 'poll_series#normal', as: :normal_questionnaire
    get 'same_choice',  to: 'poll_series#same_choice',  as: :same_choice_questionnaire
  end

  scope 'guest' do
    post 'try_out',         to: 'guests#try_out'
  end

  scope 'campaign' do
    # post ':id/predict',        to: 'campaigns#predict'
    get 'check_redeem',     to: 'campaigns#check_redeem'
  end

  scope 'questionnaire' do
    post ':id/vote',        to: 'poll_series#vote'
    get ':id/qrcode',       to: 'poll_series#generate_qrcode'
    get ':id/detail',       to: 'poll_series#detail'
  end

  scope 'friend' do
    post 'add_celebrity',   to: 'friends#add_celebrity'
    post 'add_friend' ,     to: 'friends#add_friend'
    post 'block',           to: 'friends#block_friend'
    post 'unblock',         to: 'friends#unblock_friend'
    post 'mute',            to: 'friends#mute_friend'
    post 'unmute',          to: 'friends#unmute_friend'
    post 'accept',          to: 'friends#accept_friend'
    post 'deny',            to: 'friends#deny_friend'
    post 'unfriend',        to: 'friends#unfriend'
    post 'add_close_friend',  to: 'friends#add_close_friend'
    post 'unclose_friend',  to: 'friends#unclose_friend'
    get 'all',              to: 'friends#list_friend'
    get 'request',          to: 'friends#list_request'
    get 'list_following',   to: 'friends#my_following'
    get 'list_follower',    to: 'friends#my_follower'
    get 'search',           to: 'friends#search_friend'
    post 'following',       to: 'friends#following'
    post 'unfollow',        to: 'friends#unfollow'
    get 'list_friend',      to: 'friends#list_of_friend'
    get 'profile',          to: 'friends#profile'
    get 'polls',            to: 'friends#list_of_poll'
    get 'votes',            to: 'friends#list_of_vote'
    get 'watched',          to: 'friends#list_of_watched'
    get 'groups',           to: 'friends#list_of_group'
    get 'friend_of_friend', to: 'friends#friend_of_friend'
    get 'following_of_friend', to: 'friends#following_of_friend'
    get 'follower_of_friend',  to: 'friends#follower_of_friend'
  end

  scope 'group' do
    post 'build',             to: 'group#build_group'
    post ':id/invite',        to: 'group#add_friend_to_group'
    post ':id/accept',        to: 'group#accept_group'
    post ':id/cancel',        to: 'group#cancel_group'
    post ':id/leave',         to: 'group#leave_group'
    post 'delete_group',      to: 'group#delete_group'
    get 'all',                to: 'group#my_group'
    get ':id/detail',         to: 'group#detail_group'
    get ':id/polls',          to: 'group#poll_group'
    post ':id/delete_poll',   to: 'group#delete_poll'
    post ':id/notification',  to: 'group#notification'
    post ':id/group_update',  to: 'group#group_update'
    post ':id/kick_member',   to: 'group#kick_member'
    post ':id/promote_admin', to: 'group#promote_admin'
  end

  scope 'member' do
    get 'recommendations',    to: 'members#recommendations'
    get 'detail_friend',      to: 'members#detail_friend'
    get 'stats',              to: 'members#stats'
    post 'update_profile',    to: 'members#update_profile', as: :update_profile
    post 'setting_default',   to: 'members#setting_default'
    post 'update_group',      to: 'members#update_group', as: :update_group
    get 'clear',              to: 'members#clear', as: :clear_history
    get 'list_reward',        to: 'campaigns#list_reward'
    get 'notify',         to: 'members#notify'
    get ':member_id/activity',    to: 'members#activity'
    get ':member_id/all_request', to: 'members#all_request'
    get ':member_id/list_block',  to: 'members#list_block'
    get 'profile',                to: 'members#my_profile'
    post 'activate',              to: 'members#activate'
    post ':member_id/block',      to: 'members#block'
    post 'verify_email',          to: 'members#verify_email'
    post ':member_id/report',     to: 'members#report'
    post ':member_id/public_id',  to: 'members#public_id'
    post ':member_id/request_code', to: 'members#send_request_code'
    post ':member_id/purchase_point', to: 'purchase#add_point'
    post ':member_id/subscribe', to: 'purchase#subscribe'
    get ':member_id/load_form',  to: 'profiles#load_form'
    post ':member_id/personal_detail',  to: 'profiles#update_personal_detail'
    post ':member_id/unrecomment',  to: 'members#unrecomment'          
  end

  scope 'poll' do
    get ':id/qrcode',       to: 'polls#generate_qrcode'
    post 'poke_dont_vote',  to: 'polls#poke_dont_vote', as: :poke_dont_vote
    post 'poke_dont_view',  to: 'polls#poke_dont_view', as: :poke_dont_view
    post 'poke_view_no_vote',  to: 'polls#poke_view_no_vote', as: :poke_view_no_vote
    post 'new_generate_qrcode',    to: 'polls#new_generate_qrcode'
    get 'series',           to: 'polls#series',  as: :series_poll
    post 'create',          to: 'polls#create_poll'
    get 'guest_poll',       to: 'polls#guest_poll'
    get 'tags',             to: 'polls#tags'
    get 'qrcode',           to: 'polls#qrcode'
    get 'my_poll',          to: 'polls#my_poll'
    get 'my_vote',          to: 'polls#my_vote'
    get 'my_watched',       to: 'polls#my_watched'
    get   ':id/choices',    to: 'polls#choices'
    post  ':id/vote',       to: 'polls#vote'
    post  ':id/view',       to: 'polls#view'
    post ':id/hide',        to: 'polls#hide'
    post ':id/watch',       to: 'polls#watch'
    post ':id/unwatch',     to: 'polls#unwatch'
    post ':id/report',      to: 'polls#report'
    post 'share/:id',       to: 'polls#share'
    post 'unshare/:id',     to: 'polls#unshare'
    post ':id/comments',     to: 'polls#comment'
    get ':id/comments',       to: 'polls#load_comment'
    delete ':id/comments/:comment_id/delete',  to: 'polls#delete_comment'
    delete ':id/delete',           to: 'polls#delete_poll'
    get 'public_timeline',            to: 'polls#public_poll'
    get 'friend_following_timeline',  to: 'polls#friend_following_poll'
    get 'overall_timeline',           to: 'polls#overall_timeline'
    get 'group_timeline',             to: 'polls#group_timeline'
    get 'reward_timeline',            to: 'polls#reward_poll_timeline'

    get ':member_id/public_timeline',            to: 'polls#public_poll'
    get ':member_id/friend_following_timeline',  to: 'polls#friend_following_poll'
    get ':member_id/overall_timeline',           to: 'polls#overall_timeline'
    get ':member_id/group_timeline',             to: 'polls#group_timeline'
    get ':member_id/reward_timeline',            to: 'polls#reward_poll_timeline'

    get ':id/detail',       to: 'polls#detail'
    post ':id/close',      to: 'polls#set_close'

    post ':id/open_comment',   to: 'polls#open_comment'
    post ':id/close_comment',   to: 'polls#close_comment'
  end


  scope "authen" do
    get 'signin',           to: 'authen_sentai#signin', as: :authen_signin
    get 'signup',           to: 'authen_sentai#signup', as: :authen_signup
    delete 'signout',          to: 'authen_sentai#signout', as: :authen_signout
    post 'signin_sentai',   to: 'authen_sentai#signin_sentai'
    post 'signup_sentai',   to: 'authen_sentai#signup_sentai'
    post 'update_sentai',   to: 'authen_sentai#update_sentai'
    post 'change_password', to: 'authen_sentai#change_password'
    post 'facebook',        to: 'facebook#login'
  end

  scope 'stats' do
    get 'dashboard',      to: 'stats#dashboard',  as: :stats_dashboard
    get 'polls',          to: 'stats#polls',  as: :stats_polls
    get 'votes',          to: 'stats#votes',   as: :stats_votes
    get 'users',          to: 'stats#users',  as: :stats_users
    get 'groups',         to: 'stats#groups', as: :stats_groups
  end

  scope 'manage/dashboard' do
    get '',               to: 'admin#dashboard',  as: :admin_management_dashboard
    get 'report',         to: 'admin#report',     as: :admin_report_dashboard
    get 'report/load_reason_poll',  to: 'admin#load_reason_poll'
    get 'report/load_reason_member',  to: 'admin#load_reason_member' 
    
    get 'admin_signout',  to: 'admin#signout',    as: :admin_signout

    post 'login_as',  to: 'admin#login_as', as: :login_as
    resources :invites
    resources :commercials
  end

  get '/hashtag',  to: 'polls#hashtag'
  get '/hashtag_popular', to: 'polls#hashtag_popular'

  get '/tags',  to: 'tags#index'
  get 'search_autocmp_tags',  to: 'tags#search_autocmp_tags'

  scope 'tags' do
    get 'all',      to: 'tags#list_tag_all'
    get 'search',   to: 'tags#search_tag'
  end

  scope 'company' do
    get 'members',  to: 'companies#list_members',  as: :company_members
    get 'members/add',  to: 'companies#add_member',  as: :company_add_member
    post 'add_user_to_group', to: 'companies#add_user_to_group',  as: :add_user_to_group
    get 'invites',  to: 'companies#invites',    as: :company_invites
    get 'invites/via_email',  to: 'companies#via_email',  as: :via_email
    post 'invites/send_email', to: 'companies#send_email'

    post 'download_csv', to: 'companies#download_csv', as: :download_csv
    post 'download_excel', to: 'companies#download_excel', as: :download_excel
    post 'download_txt', to: 'companies#download_txt', as: :download_txt

    get '/invites/new', to: 'companies#new',  as: :invites_new
    delete '/remove_member',  to: 'companies#remove_member',  as: :remove_member_group
  end

  scope 'api/group/:group_id' do
    get 'polls',  to: 'companies#polls'
    get 'polls/:id/detail',  to: 'companies#poll_detail'
  end

  get '/profile', to: 'members#profile',  as: :my_profile
  delete 'delete_avatar',  to: 'members#delete_avatar', as: :delete_avatar
  delete 'delete_cover',  to: 'members#delete_cover', as: :delete_cover
  delete 'delete_photo_group',  to: 'members#delete_photo_group', as: :delete_photo_group
  get '/qrcode',  to: 'polls#generate_qrcode'

  get '/dashboard',  to: 'home#dashboard', as: :dashboard
  post '/invites',    to: 'companies#create'
  
  get '/campaigns_polls',  to: 'campaigns#polls'
  get 'questionnaire',  to: 'poll_series#index'
  post '/scan_qrcode',      to: 'polls#scan_qrcode'
  post '/check_valid_email', to: 'members#check_valid_email'
  post '/check_valid_username', to: 'members#check_valid_username'

  get 'poll_latest',      to: 'polls#poll_latest', as: :poll_latest
  get 'poll_popular',      to: 'polls#poll_popular', as: :poll_popular

  post 'templates',       to: 'templates#new_or_update'
  get  'templates',        to: 'templates#poll_template'

  get 'users_activate',     to: 'members#activate_account', as: :users_activate
  get 'users_signin',      to: 'authen_sentai#signin',  as: :users_signin
  get 'users_signup',      to: 'authen_sentai#signup',  as: :users_signup
  get 'waiting_approve',  to: 'authen_sentai#waiting_approve',  as: :waiting_approve

  get 'users_signup/brand',   to: 'authen_sentai#signup_brand', as: :users_signup_brand
  get 'users_signup/company', to: 'authen_sentai#signup_company', as: :users_signup_company

  get 'users_signout',     to: 'authen_sentai#signout', as: :users_signout
  get 'users_forgotpassword',   to: 'authen_sentai#forgot_pwd', as: :users_forgotpassword
  get 'users_resetpassword/:id', to: 'authen_sentai#reset_pwd', as: :users_resetpassword
  
  post 'users_signin',     to: 'authen_sentai#signin_sentai'
  post 'users_signup',     to: 'authen_sentai#signup_sentai'
  post 'users_forgotpassword',  to: 'authen_sentai#forgot_password'
  post 'users_resetpassword',  to: 'authen_sentai#reset_password'

  get '/check_valid_company_team',  to: 'invites#check_valid_company_team'

  match 'users_signin' => 'authen_sentai#signin', via: [:get, :post]

  root to: 'home#index'
  authenticate :admin do
    mount Sidekiq::Web => '/sidekiq'
  end
end

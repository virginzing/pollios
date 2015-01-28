require 'sidekiq/web'
require 'api_constraints'

Pollios::Application.routes.draw do


  get 'services', to: 'select_services#index',  as: :select_services

  get 'list_members', to: 'members#list_members'
  
  mount ApiTaster::Engine => "/api_taster"
  
  resources :activity_feeds

  namespace :api, defaults: {format: 'json'} do
    scope module: :v1, constraints: ApiConstraints.new(version: 1, default: :true) do
      scope 'group/:group_id' do
        get 'polls',  to: 'companies#polls'
        get 'polls/:id/detail', to: 'companies#poll_detail'
        get 'questionnaires/:id/detail',  to: 'companies#questionnaire_detail'
        get 'questionnaires/:id/suggests',  to: 'companies#load_suggest'
      end

      scope 'company' do
        get 'groups',     to: 'companies#company_groups'
        get 'members',    to: 'companies#company_members'
        get 'polls',      to: 'companies#company_polls'
      end

      scope 'surveyor' do
        get 'polls',      to: 'surveyors#list_polls'
        get 'polls/:id/detail', to: 'surveyors#poll_detail'
        get 'polls/:id/members_surveyable', to: 'surveyors#members_surveyable'
        get 'questionnaires/:id/members_surveyable',  to: 'surveyors#members_surveyable_questionnaire'
        post 'polls/:id/survey',  to: 'surveyors#survey'
        post 'polls/list_of_survey', to: 'surveyors#list_of_survey'

        post 'questionnaires/survey', to: 'surveyors#survey_questionnaire'
      end

      scope 'campaign' do
        post 'redeem_code',  to: 'campaigns#redeem_code'
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
  resources :comments

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
    post ':id/un_see',      to: 'poll_series#un_see'
    post ':id/save_later',  to: 'poll_series#save_later'
    post ':id/un_save_later', to: 'poll_series#un_save_later'
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
    get 'save_poll_later',  to: 'friends#list_of_save_poll_later'
    get 'groups',           to: 'friends#list_of_group'
    get 'bookmarks',        to: 'friends#list_of_bookmark'
    get 'friend_of_friend', to: 'friends#friend_of_friend'
    get 'following_of_friend', to: 'friends#following_of_friend'
    get 'follower_of_friend',  to: 'friends#follower_of_friend'
    get 'collection_profile',  to: 'friends#collection_profile'
  end

  scope 'group' do
    post 'build',             to: 'group#build_group'
    post ':id/invite',        to: 'group#add_friend_to_group'
    post ':id/accept',        to: 'group#accept_group'
    post ':id/accept_request_group',  to: 'group#accept_request_group'
    post ':id/cancel_ask_join_group', to: 'group#cancel_ask_join_group'
    post ':id/cancel',        to: 'group#cancel_group'
    post ':id/leave',         to: 'group#leave_group'
    post 'delete_group',      to: 'group#delete_group'
    get 'all',                to: 'group#my_group'
    get ':id/detail',         to: 'group#detail_group'
    get ':id/polls',          to: 'group#poll_available_group'
    post ':id/delete_poll',   to: 'group#delete_poll'
    post ':id/notification',  to: 'group#notification'
    post ':id/group_update',  to: 'group#group_update'
    post ':id/kick_member',   to: 'group#kick_member'
    post ':id/promote_admin', to: 'group#promote_admin'
    post ':id/edit_group',    to: 'group#edit_group'
    post ':id/request_group', to: 'group#request_group'
    # get 'load_activity_feed',  to: 'group#load_activity_feed', as: :group_activity_feed
  end

  scope 'feedback' do
    resources :branches

    
    get 'dashboard',  to: 'feedback#dashboard', as: :feedback_dashboard
    get 'polls',      to: 'feedback_poll#index',     as: :feedback_polls

    get 'polls/new',  to: 'feedback_poll#new',  as: :new_feedback_poll


    get 'questionnaires', to: 'feedback_questionnaire#index', as: :feedback_questionnaires
    
    scope 'questionnaire' do
      get 'new',      to: 'feedback_questionnaire#new',  as: :new_feedback_questionnaire
      post 'create',  to: 'feedback_questionnaire#create',  as: :create_feedback_questionnaire

      get ':id/reports',      to: 'feedback_reports#collection',  as: :collection_feedback_report
      get ':id/reports/branch/:branch_id',  to: 'feedback_reports#each_branch', as: :each_branch_feedback_report

      get ':id/qrcode/:branch_id',  to: 'feedback_questionnaire#qrcode',  as: :qrcode_feedback_questionnaire

      get 'reports',  to: 'feedback_questionnaire#reports', as: :all_feedback_report

      delete ':id/delete',  to: 'feedback_questionnaire#destroy', as: :delete_collection_feedback
    end

    scope 'poll' do
      get ':id/reports',  to: 'feedback_reports#polls', as: :poll_feedback_report
      get 'reports',      to: 'feedback_poll#reports',  as: :all_poll_report
    end

    scope 'collection' do
      get ':id',      to: 'feedback_questionnaire#collection', as: :collection_feedback_questionnaire
      get ':id/edit', to: 'collection_poll_series#edit', as: :edit_collection_feedback 
      put ':id',      to: 'collection_poll_series#update',   as: :update_collection_feedback 
      get ':id/:branch_id/:questionnaire_id',    to: 'branches#detail',  as: :collection_feedback_branch_detail
    end

    scope 'campaigns' do
      get '',       to: 'feedback_campaigns#index', as: :feedback_campaigns
      get 'new',    to: 'feedback_campaigns#new', as: :new_feedback_campaign
      post 'create',  to: 'feedback_campaigns#create',  as: :create_feedback_campaign
      get ':id/edit', to: 'feedback_campaigns#edit', as: :edit_feedback_campaign
      put ':id',   to: 'feedback_campaigns#update',  as: :update_feedback_campaign
      delete ':id', to: 'feedback_campaigns#destroy'
    end
  end

  scope 'member' do
    get 'special_code', to: 'members#special_code'
    get 'recommendations',    to: 'members#recommendations'
    get 'detail_friend',      to: 'members#detail_friend'
    get 'stats',              to: 'members#stats'
    post 'update_profile',    to: 'members#update_profile', as: :update_profile
    post ':member_id/setting_default',   to: 'members#setting_default'
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
    post ':member_id/device_token', to: 'members#device_token'
  end

  scope 'poll' do
    get ':id/member_voted', to: 'polls#member_voted'
    
    get 'random_poll',  to: 'polls#random_poll'
    post ':id/bookmark',  to: 'polls#bookmark'
    post ':id/un_bookmark', to: 'polls#un_bookmark'
    post ':id/un_see',  to: 'polls#un_see'
    post ':id/save_later',  to: 'polls#save_later'
    post ':id/un_save_later', to: 'polls#un_save_later'
    get ':id/qrcode',       to: 'polls#generate_qrcode'
    post 'poke_poll',       to: 'polls#poke_poll',  as: :poke_poll
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
    delete ':id/delete_share',     to: 'polls#delete_poll_share'
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
    post 'signup_sentai_via_company', to: 'authen_sentai#signup_sentai_via_company',  as: :authen_signup_via_company
    post 'multi_signup_via_company',  to: 'companies#multi_signup_via_company', as: :multi_signup_via_company
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

    get 'certification',  to: 'admin#certification', as: :admin_certification

    get 'certification/:id/edit', to: 'admin#edit_certification', as: :admin_edit_certification

    post 'certification/:id', to: 'admin#update_certification', as: :admin_update_certification

    get 'notification', to: 'admin#notification', as: :admin_notification

    post 'create_notification', to: 'admin#create_notification', as: :admin_create_notification

    get 'system_setting', to: 'system_setting#index', as: :system_setting

    get 'admin_signout',  to: 'admin#signout',    as: :admin_signout

    post 'login_as',  to: 'admin#login_as', as: :login_as


    get 'special_qrcodes',   to: 'special_qrcodes#index', as: :admin_special_qrcode

    get 'special_qrcodes/new', to: 'special_qrcodes#new', as: :admin_new_special_qrcode

    resources :special_qrcodes

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
    get 'new_poll', to: 'polls#create_new_poll', as: :create_new_poll
    
    get 'dashboard',  to: 'companies#dashboard', as: :company_dashboard
    get 'load_surveyor',  to: 'surveyor#load_surveyor'
    get 'list_group', to: 'companies#list_group'
    get 'groups',   to: 'companies#company_groups',    as: :company_groups
    get 'groups/add', to: 'companies#new_group',  as: :company_add_group
    get 'groups/:group_id', to: 'companies#group_detail', as: :company_group_detail

    get 'groups/:group_id/edit',  to: 'companies#edit_group', as: :company_edit_group
    get 'groups/:group_id/polls/:id',  to: 'companies#group_poll_detail', as: :company_group_poll_detail

    post 'groups/update_group',      to: 'companies#update_group', as: :company_update_group

    get 'groups/:group_id/polls', to: 'companies#list_polls_in_group',  as: :company_groups_polls
    get 'groups/:group_id/members', to: 'companies#list_members_in_group',  as: :company_groups_members
    delete 'groups/:group_id/destroy',  to: 'companies#destroy_group',  as: :company_destroy_group
    delete 'groups/:group_id/surveyor/:surveyor_id/destroy',  to: 'companies#remove_surveyor',  as: :company_remove_surveyor
    post 'add_user_to_group', to: 'companies#add_user_to_group',  as: :add_user_to_group
    post 'create_group',  to: 'companies#create_group', as: :company_create_group

    get 'polls',    to: 'companies#list_polls',     as: :company_polls
    get 'polls/:id',to: 'companies#poll_detail',    as: :company_polls_detail

    get 'search',   to: 'companies#search',  as: :company_search
    get 'questionnaires', to: 'companies#list_questionnaires',  as: :company_questionnaires
    delete 'polls/:id/destroy', to: 'companies#delete_poll',  as: :company_delete_poll

    get 'members',  to: 'companies#company_members',   as: :company_members

    get 'member/:id',  to: 'companies#member_detail',  as: :company_member_detail

    get 'members/add',  to: 'companies#add_member',  as: :company_add_member
    get 'members/new_add_surveyor',  to: 'companies#new_add_surveyor', as: :company_new_add_surveyor
    post 'members/add_surveyor',  to: 'companies#add_surveyor', as: :company_add_surveyor
    get 'members/search', to: 'companies#search_member',  as: :company_search_member

    delete 'remove_member',  to: 'companies#remove_member',  as: :remove_member_group
    delete 'members/remove',  to: 'companies#delete_member_company', as: :company_delete_member

    get 'invites',  to: 'companies#invites',    as: :company_invites
    get 'invites/via_email',  to: 'companies#via_email',  as: :via_email
    post 'invites/send_email', to: 'companies#send_email'

    get 'flags',  to: 'companies#flags',    as: :company_flags_poll

    post 'download_csv', to: 'companies#download_csv', as: :download_csv
    post 'download_excel', to: 'companies#download_excel', as: :download_excel
    post 'download_txt', to: 'companies#download_txt', as: :download_txt

    get 'invites/new', to: 'companies#new',  as: :invites_new

    get 'new_member', to: 'companies#new_member', as: :new_member_to_company

    get 'setting',  to: 'companies#setting',  as: :company_setting

    scope 'feedback' do
      get 'branch', to: 'companies#feedback_branch',  as: :feedback_branch
    end

    scope 'campaigns' do
      get '',       to: 'company_campaigns#index', as: :company_campaigns
      get 'new',    to: 'company_campaigns#new', as: :new_company_campaign
      post 'create',  to: 'company_campaigns#create',  as: :create_company_campaign
      get ':id/edit', to: 'company_campaigns#edit', as: :edit_company_campaign
      put ':id',   to: 'company_campaigns#update',  as: :update_company_campaign
      delete ':id', to: 'company_campaigns#destroy'
    end
    
  end

  scope 'api/group/:group_id' do
    get 'polls',  to: 'companies#polls'
    get 'polls/:id/detail',  to: 'companies#poll_detail'
  end


  scope 'm' do
    get 'home', to: 'mobiles#home', as: :mobile_home
    get 'polls',  to: 'mobiles#polls'
    get 'members',  to: 'mobiles#members'
    post 'vote_questionnaire',  to: 'mobiles#vote_questionnaire', as: :mobile_vote_questionnaire
    post 'vote_poll', to: 'mobiles#vote_poll',  as: :mobile_vote_poll

    get 'signin', to: 'mobiles#signin', as: :mobile_signin
    get 'signin_form',  to: 'mobiles#signin_form',  as: :mobile_signin_form
    get 'signup_form',  to: 'mobiles#signup_form',  as: :mobile_signup_form

    delete 'signout', to: 'mobiles#signout',  as: :mobile_signout

    post 'signup_sentai', to: 'mobiles#signup_sentai',  as: :mobile_signup_sentai
    post 'authen',  to: 'mobiles#authen'
    get 'dashboard',  to: 'mobiles#dashboard',  as: :mobile_dashboard
    get 'recent_view',  to: 'mobiles#recent_view',  as: :mobile_recent_view

    get 'close_questionnaire',  to: 'mobiles#close_questionnaire'
  end

  get '/qrcode',  to: 'mobiles#check_qrcode'
  get '/qrcode_member', to: 'mobiles#check_qrcode_member'

  get '/profile', to: 'members#profile',  as: :my_profile
  delete 'delete_avatar',  to: 'members#delete_avatar', as: :delete_avatar
  delete 'delete_cover',  to: 'members#delete_cover', as: :delete_cover
  delete 'delete_photo_group',  to: 'members#delete_photo_group', as: :delete_photo_group
  get '/qrcode',  to: 'polls#generate_qrcode'

  # get '/dashboard',  to: 'home#dashboard', as: :dashboard
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

  post 'new_sigin_sentai', to: 'authen_sentai#new_sigin_sentai', as: :new_users_signin
  
  post 'users_signin',     to: 'authen_sentai#signin_sentai'
  post 'users_signup',     to: 'authen_sentai#signup_sentai'
  post 'users_forgotpassword',  to: 'authen_sentai#forgot_password'
  post 'users_resetpassword',  to: 'authen_sentai#reset_password'

  get '/check_valid_company_team',  to: 'invites#check_valid_company_team'

  match 'users_signin' => 'authen_sentai#signin', via: [:get, :post]

  get '(errors)/:status', to: 'errors#show', constraints: { status: /\d{3}/ }

  get 'auth/:provider/callback',  to: 'mobiles#authen_facebook'
  get 'auth/failure', to: redirect('/')

  root to: 'home#index'
  authenticate :admin do
    mount Sidekiq::Web => '/sidekiq'
  end
end

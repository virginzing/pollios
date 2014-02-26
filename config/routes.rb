Pollios::Application.routes.draw do

  resources :campaigns

  resources :polls do
    resources :choices
  end
  resources :members 
  resources :poll_series

  scope 'guest' do
    post 'try_out',         to: 'guests#try_out'
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
    get 'all',              to: 'friends#list_friend'
    get 'request',          to: 'friends#list_request'
    post 'search',          to: 'friends#search_friend'
  end

  scope 'group' do
    post 'build',             to: 'group#build_group'
    post 'add_friend',        to: 'group#add_friend_to_group'
    post ':id/accept',        to: 'group#accept_group'
    post 'deny_group',        to: 'group#deny_group'
    post 'leave_group',       to: 'group#leave_group'
    post 'delete_group',      to: 'group#delete_group'
    get 'my_group',           to: 'group#my_group'
  end

  scope 'member' do
    get 'detail_friend',   to: 'members#detail_friend'
    get 'stats',           to: 'members#stats'
    get 'profile',         to: 'members#profile', as: :member_profile
    get 'clear',           to: 'members#clear', as: :clear_history
  end

  scope 'poll' do
    get 'series',           to: 'polls#series',  as: :series_poll
    post 'create',          to: 'polls#create_poll'
    post 'vote',            to: 'polls#vote_poll'
    post 'view',            to: 'polls#view_poll'
    get 'public_timeline',  to: 'polls#public_poll'
    get 'new_public_timeline',  to: 'polls#new_public_timeline'
    get 'group_timeline',   to: 'polls#group_poll'
    get 'guest_poll',       to: 'polls#guest_poll'
    get 'tags',             to: 'polls#tags'
    get 'qrcode',           to: 'polls#qrcode'
    get 'my_poll',          to: 'polls#my_poll'
    get 'my_vote',          to: 'polls#my_vote'
    get   ':id/choices',      to: 'polls#choices'
    post  ':id/vote',         to: 'polls#vote'
    post  ':id/view',         to: 'polls#view'
    post 'share/:id',       to: 'polls#share'
  end


  scope "authen" do
    get 'signin',           to: 'authen_sentai#signin', as: :authen_signin
    get 'signup',           to: 'authen_sentai#signup', as: :authen_signup
    delete 'signout',       to: 'authen_sentai#signout', as: :authen_signout
    post 'signin_sentai',   to: 'authen_sentai#signin_sentai'
    post 'signup_sentai',   to: 'authen_sentai#signup_sentai'
    post 'update_sentai',   to: 'authen_sentai#update_sentai'
  end

  get '/tags',  to: 'tags#index'
  get '/qrcode',  to: 'polls#generate_qrcode'

  root to: 'polls#index'

end

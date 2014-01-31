Pollios::Application.routes.draw do

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
    post 'all',             to: 'friends#list_friend'
    post 'request',         to: 'friends#list_request'
    post 'search',          to: 'friends#search_friend'
  end

  scope 'group' do
    post 'build',           to: 'group#build_group'
    post 'add_friend',      to: 'group#add_friend_to_group'
    post 'accept',          to: 'group#accept_group'
    post 'deny_group',      to: 'group#deny_group'
    post 'leave_group',     to: 'group#leave_group'
    post 'delete_group',    to: 'group#delete_group'
    post 'my_group',        to: 'group#my_group'
  end

  scope 'member' do
    post 'detail_friend',   to: 'members#detail_friend'
  end

  scope 'poll' do
    get 'polls',            to: 'poll#index', as: :index_poll
    post 'create',          to: 'poll#create_poll'
    post 'vote',            to: 'poll#vote_poll'
    post 'view',            to: 'poll#view_poll'
    post 'public',          to: 'poll#public_poll'
    post 'group',           to: 'poll#group_poll'
  end

  scope "authen" do
    get 'signin',           to: 'authen_sentai#signin', as: :authen_signin
    get 'signup',           to: 'authen_sentai#signup', as: :authen_signup
    get 'signout',          to: 'authen_sentai#signout', as: :authen_signout
    post 'signin_sentai',   to: 'authen_sentai#signin_sentai'
    post 'signup_sentai',   to: 'authen_sentai#signup_sentai'
    post 'update_sentai',   to: 'authen_sentai#update_sentai'
  end

  root to: 'poll#index'

end

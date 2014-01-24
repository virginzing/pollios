Pollios::Application.routes.draw do

  scope 'friend' do
    post 'add_friend' ,     to: 'friends#add_friend'
    post 'block_friend',    to: 'friends#block_friend'
    post 'unblock_friend',  to: 'friends#unblock_friend'
    post 'mute_friend',     to: 'friends#mute_friend'
    post 'unmute_friend',   to: 'friends#unmute_friend'
    post 'accept_friend',   to: 'friends#accept_friend'
    post 'deny_friend',     to: 'friends#deny_friend'
    post 'unfriend',        to: 'friends#unfriend'
    post 'list_friend',     to: 'friends#list_friend'
    post 'search_friend',   to: 'friends#search_friend'
  end

  scope 'group' do
    post 'create_group',    to: 'group#create_group'
    post 'add_friend_to_group', to: 'group#add_friend_to_group'
    post 'accept_group',    to: 'group#accept_group'
    post 'deny_group',      to: 'group#deny_group'
    post 'leave_group',     to: 'group#leave_group'
    post 'delete_group',    to: 'group#delete_group'
    post 'my_group',        to: 'group#my_group'
  end

  scope 'poll' do
    get 'polls'       ,     to: 'poll#index', as: :index_poll
    post 'create_poll',     to: 'poll#create_poll'
    post 'vote_poll',       to: 'poll#vote_poll'
    post 'list_group_poll', to: 'poll#list_group_poll'
  end

  scope "authen" do
    get 'signin',           to: 'authen_sentai#signin', as: :authen_signin
    get 'signup',           to: 'authen_sentai#signup', as: :authen_signup
    get 'signout',          to: 'authen_sentai#signout', as: :authen_signout
    post 'signin_sentai',   to: 'authen_sentai#signin_sentai'
    post 'signup_sentai',   to: 'authen_sentai#signup_sentai'
  end

  root to: 'poll#index'

end

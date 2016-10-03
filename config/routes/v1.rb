namespace 'v1' do
  devise_for :admin,
             controllers: { sessions: 'v1/admin/authentication' },
             path_names: { sign_in: 'signin', sign_out: 'signout' }

  namespace 'admin' do
    get 'dashboard', to: 'dashboard#index'
  end

  namespace 'polls' do
    get ':custom_key', to: 'polls#get'
  end
end

scope module: 'v1' do
  namespace 'groups' do
    get ':group_id', to: 'get#detail'
    get ':group_id/polls/:index', to: 'get#poll_detail'
    get ':group_id/polls/:index/result', to: 'get#poll_detail_result'

    post ':group_id/polls/close', to: 'post#close_poll'
  end
end

namespace 'v1' do
  devise_for :admin,
             controllers: { sessions: 'v1/admin/authentication' },
             path_names: { sign_in: 'signin', sign_out: 'signout' }

  namespace 'polls' do
    get ':custom_key', to: 'get#detail'

    post ':custom_key/vote', to: 'post#vote'
  end
end

scope module: 'v1' do
  namespace 'admin' do
    namespace 'dashboard' do
      get '', to: 'get#index'
    end
  end

  namespace 'groups' do
    get ':group_id', to: 'get#detail'
    get ':group_id/polls/summary', to: 'get#poll_summary'
    get ':group_id/polls/:index', to: 'get#poll_detail'
    get ':group_id/polls/:index/result', to: 'get#poll_detail_result'
    get ':group_id/polls/:index/polling', to: 'get#poll_polling'

    post ':group_id/polls/close', to: 'post#close_poll'
  end

  namespace 'auth' do
    get '/sign_out', to: 'get#sign_out'

    post '/sign_in', to: 'post#sign_in'
  end
end

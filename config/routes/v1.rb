namespace 'v1' do
  devise_for :admin, controllers: { sessions: 'v1/admin/authentication' }, path_names: { sign_in: 'signin', sign_out: 'signout' }

  namespace 'admin' do
    get 'dashboard', to: 'dashboard#index'
  end

  namespace 'polls' do
    get ':custom_key', to: 'polls#get'
  end
end


Pollios::Application.routes.draw do
  get "poll/index"
  # The priority is based upon order of creation: first created -> highest priority.
  # See how all your routes lay out with "rake routes".

  # You can have the root of your site routed with "root"
  # root 'welcome#index'

  # Example of regular route:
  #   get 'products/:id' => 'catalog#view'

  # Example of named route that can be invoked with purchase_url(id: product.id)
  #   get 'products/:id/purchase' => 'catalog#purchase', as: :purchase

  # Example resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

  scope 'friend' do
    post 'add_friend' ,     to: 'friends#add_friend'
    post 'block_friend',    to: 'friends#block_friend'
    post 'unblock_friend',  to: 'friends#unblock_friend'
    post 'accept_friend',   to: 'friends#accept_friend'
    post 'deny_friend',     to: 'friends#deny_friend'
    post 'list_friend',     to: 'friends#list_friend'
    post 'search_friend',   to: 'friends#search_friend'
  end

  scope 'poll' do
    get 'polls'       ,  to: 'poll#index', as: :index_poll
  end

  scope "authen" do
    get 'signin', to: 'authen_sentai#signin', as: :authen_signin
    get 'signup', to: 'authen_sentai#signup', as: :authen_signup
    get 'signout',  to: 'authen_sentai#signout', as: :authen_signout
    post 'signin_sentai', to: 'authen_sentai#signin_sentai'
    post 'signup_sentai', to: 'authen_sentai#signup_sentai'
  end

  root to: 'authen_sentai#signin'
  

  # Example resource route with options:
  #   resources :products do
  #     member do
  #       get 'short'
  #       post 'toggle'
  #     end
  #
  #     collection do
  #       get 'sold'
  #     end
  #   end

  # Example resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Example resource route with more complex sub-resources:
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get 'recent', on: :collection
  #     end
  #   end
  
  # Example resource route with concerns:
  #   concern :toggleable do
  #     post 'toggle'
  #   end
  #   resources :posts, concerns: :toggleable
  #   resources :photos, concerns: :toggleable

  # Example resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end
end

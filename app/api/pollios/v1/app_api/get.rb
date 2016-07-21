module Pollios::V1::AppAPI
  class Get < Grape::API
    version 'v1', using: :path
    
    resource :app do
      get '/product_keys' do
        {
          product_keys: {
            public_poll: [ENV['1_PUBLIC_POLL'], ENV['5_PUBLIC_POLL'], ENV['10_PUBLIC_POLL']],
            subscription: [ENV['1_MONTH'], ENV['1_YEAR']]
          }
        }
      end
    end
    
  end
end

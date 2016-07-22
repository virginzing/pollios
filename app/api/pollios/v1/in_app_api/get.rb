module Pollios::V1::InAppAPI
  class Get < Grape::API
    version 'v1', using: :path
    
    resource :in_app do
      resource :purchases do
        desc 'returns list of key for in-app purchases'
        get '/keys' do
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
end

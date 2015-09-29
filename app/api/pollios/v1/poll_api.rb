module Pollios::V1
  class PollAPI < Grape::API
    version 'v1', using: :path

    desc 'Hello World!!!'
    params do
      # requires :message, type: String
    end

    resource :polls do
      get :all_count do
        { count: Poll.count }
      end
    end

    get :say do
      # { m: params[:message] }
    end 
  end
end
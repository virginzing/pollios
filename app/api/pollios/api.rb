module Pollios
    class API < Grape::API
        format :json
        prefix :api

        mount Pollios::V1::PollAPI
    end
end
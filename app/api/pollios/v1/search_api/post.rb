module Pollios::V1::SearchAPI
  class Post < Grape::API
    version 'v1', using: :path

    resource :searches do
      
      resource :tags do
        desc 'clear list of searched tag'
        post '/clear' do
          Member::PollSearch.new(current_member).clear_searched_tags
        end
      end

      resource :keywords do
        desc 'clear list of searched keyword'
        post '/clear' do
          Member::MemberAndGroupSearch.new(current_member).clear_searched_keywords
        end
      end
    end
  end
end
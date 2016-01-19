module Pollios::V1::SearchAPI
  class Get < Grape::API
    version 'v1', using: :path

    resource :searches do
      
      resource :polls do
        desc 'returns list of poll searched by hashtag'
        params do
          requires :hashtag, type: String, desc: 'hashtag for searching'
        end
        get do
          polls = Member::PollSearch.new(current_member, params[:hashtag]).polls_searched
          present polls, with: Pollios::V1::Shared::PollDetailEntity, current_member: current_member
        end

        desc 'returns list of recent and popular hashtag'
        get '/tags' do
          recent_and_popular = Member::PollSearch.new(current_member)
          present recent_and_popular, with: RecentAndPopularEntity
        end
      end

      resource :members_and_groups do
        params do
          requires :keyword, type: String, desc: 'keyword(name or public_id) for searching'
        end
        desc 'returns list of member and group searched by keyword'
        get do
          members_and_groups = Member::MemberAndGroupSearch.new(current_member, params[:keyword])
          present members_and_groups, with: MemberAndGroupEntity, current_member: current_member
        end

        desc 'returns list of recent searched keyword'
        get '/keywords' do
          recent_keyword = Member::MemberAndGroupSearch.new(current_member).recent
          present :recent, recent_keyword
        end
      end

    end
  end
end
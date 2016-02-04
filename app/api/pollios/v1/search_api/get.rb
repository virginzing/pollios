module Pollios::V1::SearchAPI
  class Get < Grape::API
    version 'v1', using: :path

    resource :searches do
      
      resource :polls do
        desc 'returns list of poll searched by hashtag'
        params do
          requires :hashtag, type: String, desc: 'hashtag for searching'
          optional :index, type: Integer, desc: "starting index for polls's list in this request"
        end
        get do
          polls = Member::PollSearch.new(current_member, params[:hashtag], index: params[:index])
          present polls, poll: :polls_searched, with: Pollios::V1::Shared::PollListEntity, current_member: current_member
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

      resource :members do
        params do
          requires :keyword, type: String, desc: 'keyword(name or public_id) for searching'
        end
        desc 'returns list of member searched by keyword'
        get do
          members = Member::MemberAndGroupSearch.new(current_member, params[:keyword]).members_searched
          present :members, members, with: Pollios::V1::Shared::MemberForListEntity, current_member: current_member
        end
      end

      resource :groups do
        params do
          requires :keyword, type: String, desc: 'keyword(name or public_id) for searching'
        end
        desc 'returns list of group searched by keyword'
        get do
          groups = Member::MemberAndGroupSearch.new(current_member, params[:keyword]).groups_searched
          present :groups, groups, with: Pollios::V1::Shared::GroupEntity, current_member: current_member
        end
      end

    end
  end
end
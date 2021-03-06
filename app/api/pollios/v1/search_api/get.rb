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
          present polls, poll: :polls_searched, with: Pollios::V1::Shared::PollListEntity \
            , current_member: current_member \
            , current_member_states: Member::PollList.new(current_member).member_states_ids
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
          present members_and_groups, with: MemberAndGroupEntity \
            , current_member_linkage: Member::MemberList.new(current_member).social_linkage_ids \
            , current_member_status: Member::GroupList.new(current_member).relation_status_ids
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
          optional :index, type: Integer, desc: "starting index for members's list in this request"
        end
        desc 'returns list of member searched by keyword'
        get do
          searched = Member::MemberAndGroupSearch.new(current_member, params[:keyword], index: params[:index])
          present searched, member: :members_searched, with: Pollios::V1::Shared::MemberListEntity \
            , current_member: current_member \
            , current_member_linkage: Member::MemberList.new(current_member).social_linkage_ids
        end
      end

      resource :groups do
        params do
          requires :keyword, type: String, desc: 'keyword(name or public_id) for searching'
        end
        desc 'returns list of group searched by keyword'
        get do
          groups = Member::MemberAndGroupSearch.new(current_member, params[:keyword]).groups_searched
          present :groups, groups, with: Pollios::V1::Shared::GroupForListEntity \
            , current_member_status: Member::GroupList.new(current_member).relation_status_ids
        end
      end

    end
  end
end
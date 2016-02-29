module Pollios
  module V2::CurrentMemberAPI
    class Get < Grape::API
      version 'v2', using: :path

      resource :current_member do

        desc "returns list of current member's rewards"
        resource :rewards do
          params do
            optional :index, type: Integer, desc: "starting index for rewards's list in this request"
          end
          get do
            rewards_of_member = Member::RewardList.new(current_member, index: params[:index])
            present rewards_of_member, with: RewardListEntity
          end

          desc 'returns reward at id for current member'
          params do
            requires :id, type: Integer, desc: 'reward id'
          end
          route_param :id do
            get do
              reward = MemberReward.cached_find(params[:id])
              fail ExceptionHandler::UnprocessableEntity, "This reward doesn't exist in your rewards" \
                unless reward.member_id == current_member.id
              present reward, with: MemberRewardEntity
            end
          end
        end

      end
    
    end
  end
end

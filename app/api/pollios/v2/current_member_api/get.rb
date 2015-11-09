module Pollios
  module V2::CurrentMemberAPI
    class Get < Grape::API
      version 'v2', using: :path

      resource :current_member do

        desc "returns list of current member's rewards"
        resource :rewards do
          get do
            rewards_of_member = Member::RewardList.new(current_member, page_index: params[:page_index])
            present rewards_of_member, with: RewardListEntity
          end

          desc 'returns reward at id for current member'
          params do
            requires :id, type: Integer, desc: 'reward id'
          end
          route_param :id do
            get do
              reward = MemberReward.cached_find(params[:id])
              present reward, with: MemberRewardEntity
            end
          end
        end

      end
    
    end
  end
end

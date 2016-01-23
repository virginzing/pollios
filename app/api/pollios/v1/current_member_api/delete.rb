module Pollios::V1::CurrentMemberAPI
  class Delete < Grape::API
    version 'v1', using: :path

    resource :current_member do

      resource :rewards do

        helpers do
          def reward
            @reward = MemberReward.cached_find(params[:id])
          end
        end

        desc "delete reward if don't win"
        params do
          requires :id, type: Integer, desc: 'reward id'
        end
        route_param :id do
          delete '/delete' do
            delete_reward = Member::RewardAction.new(current_member, reward).delete
            present delete_reward, with: Pollios::V2::CurrentMemberAPI::MemberRewardEntity
          end
        end

      end
    end

  end
end
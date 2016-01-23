module Pollios::V1::CurrentMemberAPI
  class Post < Grape::API
    version 'v1', using: :path

    resource :current_member do

      resource :rewards do

        helpers do
          def reward
            @reward = MemberReward.cached_find(params[:id])
          end
        end

        desc 'claim reward if win'
        params do
          requires :id, type: Integer, desc: 'reward id'
        end
        route_param :id do
          post '/claim' do
            claim_reward = Member::RewardAction.new(current_member, reward).claim
            present claim_reward, with: Pollios::V2::CurrentMemberAPI::MemberRewardEntity
          end
        end

      end
    end

  end
end
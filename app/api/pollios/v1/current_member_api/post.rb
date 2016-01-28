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

      resource :polls do
        resource :presets do
          desc 'add new poll preset'
          params do
            requires :name, type: String, desc: "new preset's name"
            optional :description, type: String, desc: "new preset's description"
            requires :choices, type: String, desc: "new preset's choices"
          end
          post do
            new_preset = Member::PresetAction.new(current_member).add(params.except(:member_id))
            present :presets, new_preset, with: PresetEntity
          end
        end

      end
    end

  end
end
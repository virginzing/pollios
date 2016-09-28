module Pollios::V1::CurrentMemberAPI
  class Post < Grape::API
    version 'v1', using: :path

    resource :current_member do

      resource :rewards do
        helpers do
          def member_reward
            @member_reward = MemberReward.cached_find(params[:id])
          end
        end

        desc 'claim reward if win'
        params do
          requires :id, type: Integer, desc: 'reward id'
        end
        route_param :id do
          post '/claim' do
            claim_reward = Member::RewardAction.new(current_member, member_reward).claim
            present claim_reward, with: Pollios::V2::CurrentMemberAPI::MemberRewardEntity
          end
        end
      end

      resource :devices do
        desc 'add new device'
        params do
          requires :device_token, type: String, desc: 'device token'
          requires :receive_notification, type: Boolean, desc: 'true when want to receive notification'
          requires :model, type: Hash do
            requires :name, type: String, desc: 'device name'
            requires :type, type: String, desc: 'device type'
            requires :version, type: String, desc: 'device version'
          end
          requires :os, type: Hash do
            requires :name, type: String, desc: 'os name'
            requires :version, type: String, desc: 'os version'
          end
        end
        post do
          params[:token] = params.delete(:device_token)

          member_device_action = Member::DeviceAction.new(current_member)
          present :devices, member_device_action.create(params), with: DeviceEntity
        end
      end

      resource :polls do
        resource :presets do
          desc 'add new poll preset'
          params do
            requires :name, type: String, desc: "new preset's name"
            optional :description, type: String, desc: "new preset's description"
            requires :choices, type: String, desc: "new preset's choices", regexp: /.+,.+/
          end
          post do
            new_preset = Member::PresetAction.new(current_member).add(params.except(:member_id))
            present :presets, new_preset, with: PresetEntity
          end
        end
      end

      resource :invites do
        desc 'send invite to join Pollios with email'
        params do
          requires :email_list, type: Array[String], desc: 'list of email to invite'
        end
        post '/email' do
          Member::InviteUser.new(current_member).by_email(params[:email_list])
        end
      end      

    end

  end
end
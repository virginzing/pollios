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
      
      resource :polls do
        resource :presets do
          desc 'delete poll preset'
          params do
            requires :index, type: Integer, desc: "preset's index"
          end
          route_param :index do
            delete '/delete' do
              presets = Member::PresetAction.new(current_member).delete(params[:index])
              present :presets, presets, with: PresetEntity
            end
          end
        end
      end

      resource :notifications do
        helpers do
          def notification_list
            @notification_list = current_member.received_notifies.where('id IN (?)', params[:ids])
          end
        end
        params do
          requires :ids, type: Array[Integer], desc: 'list of notification id'
        end
        desc 'delete notifications'
        delete '/delete' do
          Member::NotificationAction.new(current_member, notification_list).hide
        end
      end

      resource :settings do
        resource :devices do
          params do
            requires :id, type: Integer, desc: 'device id'
          end
          route_param :id do
            delete do
              member_device_action = Member::DeviceAction.new(current_member, Apn::Device.find(params[:id]))
              present :devices, member_device_action.delete, with: DeviceEntity
            end
          end
        end
      end
    end

  end
end
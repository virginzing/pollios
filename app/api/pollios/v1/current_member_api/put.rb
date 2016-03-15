module Pollios::V1::CurrentMemberAPI
  class Put < Grape::API
    version 'v1', using: :path

    resource :current_member do

      helpers do
        def current_member_setting
          @current_member_setting = Member::SettingUpdate.new(current_member)
        end
      end

      resource :settings do

        desc "update current member's profile details"
        params do
          optional :name, type: String, desc: 'new fullname'
          optional :description, type: String, desc: 'new description'
          optional :avatar, type: String, desc: 'new avatar'
          optional :cover_preset, type: Integer, desc: 'new cover preset id'
          optional :cover, type: String, desc: 'new cover URL'

          mutually_exclusive :cover_preset, :cover
        end
        put '/profile' do
          update_profile = current_member_setting.profile(params)
          present update_profile, with: Pollios::V1::Shared::MemberEntity
        end

        desc "update current member's public_id"
        params do
          requires :public_id, type: String, desc: 'new public id'
        end
        put '/public_id' do
          current_member_setting.public_id(params)
          present publid_id: current_member.public_id
        end

        desc "update current member's personal"
        params do
          optional :birthday, type: Date, desc: 'date of birth'
          optional :gender, type: String, values: %w(male female other), desc: 'gender'
        end
        put '/personal' do
          update_personal = current_member_setting.personal(params)
          present update_personal, with: SettingPersonalEntity
        end

        desc "update current member's notifications setting (true is turn on notification when)"
        params do
          requires :group, type: Boolean, desc: 'new poll in group'
          requires :friend, type: Boolean, desc: 'new poll from friends & followings'
          requires :public, type: Boolean, desc: 'new poll in public'
          requires :request, type: Boolean, desc: 'new friend or group request'
          requires :join_group, type: Boolean, desc: 'new member joined groups'
          requires :watch_poll, type: Boolean, desc: 'new vote or new comment'
        end
        put '/notifications' do
          current_member_setting.notifications(params)
          present notifications: current_member.notification
        end

        desc "returns list of current member's devices"
        params do
          requires :id, type: Integer, desc: 'device id'
          optional :receive_notification, type: Boolean, desc: 'true when want to receive notification'
          optional :model, type: Hash do
            requires :name, type: String, desc: 'device name'
            requires :type, type: String, desc: 'device type'
            requires :version, type: String, desc: 'device version'
          end
          optional :os, type: Hash do
            requires :name, type: String, desc: 'os name'
            requires :version, type: String, desc: 'os version'
          end
        end
        resource :devices do
          route_param :id do
            put do
              member_device_action = Member::DeviceAction.new(current_member, Apn::Device.find(params[:id]))
              present :devices, member_device_action.undate_info(params), with: DeviceEntity
            end
          end
        end
      end

      resource :polls do
        resource :presets do
          desc 'edit poll preset'
          params do
            requires :name, type: String, desc: "new preset's name"
            optional :description, type: String, desc: "new preset's description"
            requires :choices, type: String, desc: "new preset's choices"
            requires :index, type: Integer, desc: "preset's index"
          end
          route_param :index do
            put '/edit' do
              presets = Member::PresetAction.new(current_member).edit(params[:index], params.except(:member_id, :index))
              present :presets, presets, with: PresetEntity
            end
          end
        end
      end
    end

  end
end
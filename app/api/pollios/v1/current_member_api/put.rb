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

        desc "update current member's notifications setting"
        put '/notifications' do
        end
      end
    end

  end
end
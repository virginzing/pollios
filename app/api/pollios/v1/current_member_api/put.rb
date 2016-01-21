module Pollios::V1::CurrentMemberAPI
  class Put < Grape::API
    version 'v1', using: :path

    resource :current_member do

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
          update_profile = Member::SettingUpdate.new(current_member).profile(params)
          present update_profile, with: Pollios::V1::Shared::MemberEntity
        end

        desc "update current member's public_id"
        put '/public_id' do
        end

        desc "update current member's personal"
        put '/personal' do
        end

        desc "update current member's notifications setting"
        put '/notifications' do
        end
      end
    end

  end
end
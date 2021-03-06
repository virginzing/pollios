module Pollios::V1::CurrentMemberAPI
  class Get < Grape::API
    version 'v1', using: :path

    resource :current_member do

      resource :settings do
        desc "returns current member's account details"
        get '/account' do
          present current_member, with: SettingAccountEntity
        end

        desc "returns current member's public id"
        get '/public_id' do
          present public_id: current_member.public_id
        end

        desc "returns current member's personal details"
        get '/personal' do
          present current_member, with: SettingPersonalEntity
        end

        desc "returns current member's notifications setting"
        get '/notifications' do
          present notifications: current_member.notification
        end

        desc "returns list of current member's devices"
        get '/devices' do
          devices_of_member = Member::DeviceList.new(current_member).all_device
          present :devices, devices_of_member, with: DeviceEntity
        end
      end

      desc "returns list of current member's notifications"
      resource :notifications do
        params do
          optional :index, type: Integer, desc: "starting index for notification's list in this request"
          optional :clear_new_count, type: Boolean, default: true, desc: "should clear member's new notification count"
        end
        get do
          options = { index: params[:index], clear_new_count: params[:clear_new_count] }
          notifications_for_member = Member::NotificationList.new(current_member, options)
          present notifications_for_member, with: NotificationListEntity
        end
      end

      desc '!!deprecated: returns old reward data with maintenance mode'
      resource :rewards do

        helpers do
          def old_reward_data_with_maintenance_mode
            @old_reward_data_with_maintenance_mode ||= {
              reward_info: {
                reward_id: 0,
                created_at: (Time.zone.now).to_i
              },
              campaign_detail: {
                how_to_redeem: '-',
                reward_details: {
                  title: 'This service is currently unavailable',
                  detail: "We're sorry, but the reward service is currently not working. Please wait for our new version. Update coming soon!",
                  expire: (Time.zone.now + 100.years).to_i
                },
                owner_info: Pollios::V1::Shared::MemberEntity.default_pollios_member
              }
            }
          end
        end

        get do
          present rewards: [
            old_reward_data_with_maintenance_mode
          ]
        end

        desc 'returns details of old reward data with maintenance mode'
        get '/0' do
          old_reward_data_with_maintenance_mode
        end
      end


      resource :requests do
        helpers do
          def requests_for_member
            @requests_for_member = Member::RequestList.new(current_member \
              , clear_new_request_count: params[:clear_new_request_count])
          end

          def member_listing
            @member_listing ||= Member::MemberList.new(current_member)
          end

          def group_listing
            @group_listing ||= Member::GroupList.new(current_member)
          end

          def recommendations
            @recommendations ||= Member::Recommendation.new(current_member)
          end
        end

        desc 'returns all requests related to current member'
        params do
          optional :clear_new_request_count, type: Boolean, default: true, desc: "should clear member's new request count"
        end
        get do
          present requests_for_member, with: RequestListEntity
        end

        desc 'return all requests to groups which current member is admin'
        get '/group_admins' do
          present requests_for_member, with: RequestListEntity, only: [:group_admins]
        end

        resource :friends do
          desc 'returns list of incoming friends requests'
          get '/incoming' do
            present :members, member_listing.friend_request \
            , with: Pollios::V1::Shared::MemberForListEntity
          end

          desc 'returns list of outgoing friends requests'
          get '/outgoing' do
            present :members, member_listing.your_request \
            , with: Pollios::V1::Shared::MemberForListEntity
          end
        end

        resource :groups do
          desc 'returns list of incoming groups requests'
          get '/incoming' do
            present :groups, group_listing.got_invitations \
            , with: Pollios::V1::Shared::GroupForListEntity
          end

          desc 'returns list of outgoing groups requests'
          get '/outgoing' do
            present :groups, group_listing.requesting_to_joins \
            , with: Pollios::V1::Shared::GroupForListEntity
          end
        end

        resource :recommendations do
          desc 'returns list of recommend official member'
          get '/officials' do
            present :members, recommendations.officials \
            , with: Pollios::V1::Shared::MemberForListEntity
          end

          desc 'returns list of recommend member'
          get '/friends' do
            present :members, recommendations.friends \
            , with: Pollios::V1::Shared::MemberForListEntity
          end

          desc 'returns list of recommend member from facebook'
          get '/facebook' do
            present :members, recommendations.facebooks \
            , with: Pollios::V1::Shared::MemberForListEntity
          end

          desc 'returns list of recommend group'
          get '/groups' do
            present :groups, recommendations.groups \
            , with: Pollios::V1::Shared::GroupForListEntity
          end
        end
      end

      desc 'returns notification and request counts for current member'
      get '/badges' do
        {
          notifications: current_member.notification_count,
          requests: current_member.request_count
        }
      end

      resource :polls do

        helpers do
          def polls_of_member
            @polls_of_member ||= Member::PollList.new(current_member, index: params[:index])
          end
        end

        params do
          optional :index, type: Integer, desc: "starting index for polls's list in this request"
        end

        desc "returns list of member's bookmarked poll"
        get '/bookmarks' do
          present polls_of_member, poll: :bookmarks, with: Pollios::V1::Shared::PollListEntity \
            , current_member: current_member \
            , current_member_states: polls_of_member.member_states_ids
        end

        desc "returns list of member's saved vote later poll"
        get '/saved' do
          present polls_of_member, poll: :saved, with: Pollios::V1::Shared::PollListEntity \
            , current_member: current_member \
            , current_member_states: polls_of_member.member_states_ids
        end

        desc "returns list of member's poll presets"
        get '/presets' do
          presets = Member::PresetList.new(current_member).presets
          present :presets, presets, with: PresetEntity
        end
      end
    end

  end
end

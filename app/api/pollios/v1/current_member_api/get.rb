module Pollios::V1::CurrentMemberAPI
  class Get < Grape::API
    version 'v1', using: :path
    
    resource :current_member do

      desc "returns list of current member's notifications"
      resource :notifications do
        params do
          optional :index, type: Integer, desc: "starting index for notification's list in this request"
          optional :clear_new_count, type: Boolean, desc: "should clear member's new notification count"
        end
        get do
          options = { index: params[:index], clear_new_count: params[:clear_new_count] }
          notifications_for_member = Member::NotificationList.new(current_member, options)
          present notifications_for_member, with: NotificationListEntity
        end
      end

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

      desc 'returns all requests related to current member'
      resource :requests do
        params do
          optional :clear_new_request_count, type: Boolean, desc: "should clear member's new request count"
        end
        get do
          options = { clear_new_request_count: params[:clear_new_request_count] }
          requests_for_member = Member::RequestList.new(current_member, options)
          present requests_for_member, with: RequestListEntity
        end

        desc 'return all requests to groups which current member is admin'
        get '/group_admins' do
          requests_for_member = Member::RequestList.new(current_member)
          present requests_for_member, with: RequestListEntity, only: [:group_admins]
        end
      end

      desc 'returns notification and request counts for current member'
      get '/badges' do
        { 
          notifications: current_member.notification_count, 
          requests: current_member.request_count
        }
      end
    end
    
  end
end

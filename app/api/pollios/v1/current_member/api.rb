module Pollios::V1::CurrentMember
  class API < Grape::API
    version 'v1', using: :path
    
    resource :current_member do

      desc "returns list of member's notifications"
      resource :notifications do
        params do
          optional :page_index, type: Integer, desc: "page index for notification's pagination"
          optional :clear_new_count, type: Boolean, desc: "should clear member's new notification count"
        end
        get do
          notifications_for_member = Member::NotificationList.new(current_member, {:page_index => params[:page_index], :clear_new_count => params[:clear_new_count]})
          present notifications_for_member, with: NotificationListEntity
        end
      end

      desc "returns list of member's rewards"
      resource :rewards do
        get do
          rewards_of_member = Member::RewardList.new(current_member, {:page_index => params[:page_index]})
          present rewards_of_member, with: RewardListEntity
        end
      end

      desc "returns all requests related to member"
      resource :requests do
        params do
          optional :clear_new_request_count, type: Boolean, desc: "should clear member's new request count"
        end
        get do
          requests_for_member =  Member::RequestList.new(current_member)
          present requests_for_member, with: RequestListEntity
        end
      end

    end
    
  end
end
module Pollios::V1::Request
  class API < Grape::API
    version 'v1', using: :path

    helpers do
      def member
        @member ||= Member.cached_find(params[:id])
      end

      def verify_viewing_member_right
        error!("403 Forbidden: not allowing this operation on other member", 403) unless member.id == current_member.id
      end
    end

    resource :members do

      desc "returns all requests related to member"
      resource :requests do
        params do
          optional :clear_new_request_count, type: Boolean, desc: "should clear member's new request count"
        end
        get do
          requests_for_member = Member::RequestList.new(current_member)
          present requests_for_member, with: RequestListEntity
        end
      end

    end

  end 
end 
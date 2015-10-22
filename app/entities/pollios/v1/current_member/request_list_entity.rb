module Pollios::V1::CurrentMember
  class RequestListEntity < Pollios::V1::BaseEntity
    expose :incoming_requests do |object, options|
      Pollios::V1::Shared::MemberForListEntity.represent object.incoming_requests, current_member_linkage: current_member_linkage
    end

    expose :outgoing_requests do |object, options|
      Pollios::V1::Shared::MemberForListEntity.represent object.outgoing_requests, current_member_linkage: current_member_linkage
    end

    expose :group_invitations
    expose :group_requests

    def current_member_linkage
      @current_member_linkage ||= Member::MemberList.new(object.member).social_linkage_ids
    end
  end
end
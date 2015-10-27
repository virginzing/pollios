module Pollios::V1::CurrentMember
  class RequestListEntity < Pollios::V1::BaseEntity

    expose_members :incoming_requests
    expose_members :outgoing_requests

    expose :group_invitations
    expose :group_requests

    def current_member_linkage
      @current_member_linkage ||= Member::MemberList.new(object.member).social_linkage_ids
    end
  end
end
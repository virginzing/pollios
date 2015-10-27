module Pollios::V1::CurrentMember
  class RequestListEntity < Pollios::V1::BaseEntity

    expose :friends do
      expose_members :friends_incoming, as: :incoming
      expose_members :friends_outgoing, as: :outgoing
    end

    expose :groups do
      expose :group_invitations, as: :incoming
      expose :group_requests, as: :outgoing
    end

    def current_member_linkage
      @current_member_linkage ||= Member::MemberList.new(object.member).social_linkage_ids
    end
  end
end
module Pollios::V1::CurrentMember
  class RequestListEntity < Pollios::V1::BaseEntity

    expose :friends do
      expose_members :friends_incoming, as: :incoming
      expose_members :friends_outgoing, as: :outgoing
    end

    expose :groups do
      expose :group_invitations, as: :incoming, with: Pollios::V1::Shared::GroupEntity
      expose :group_requests, as: :outgoing, with: Pollios::V1::Shared::GroupEntity
    end

    expose :admin_groups, with: Pollios::V1::Shared::GroupForAdminListEntity
    expose :recommendations 

    def recommendations
      []
    end

    def current_member_linkage
      @current_member_linkage ||= Member::MemberList.new(object.member).social_linkage_ids
    end
  end
end
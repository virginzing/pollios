module Pollios::V1::CurrentMemberAPI
  class RequestListEntity < Pollios::V1::BaseEntity

    expose :friends do
      expose_members :friends_incoming, as: :incoming
      expose_members :friends_outgoing, as: :outgoing
    end

    expose :groups do
      expose_groups :group_invitations, as: :incoming
      expose_groups :group_requests, as: :outgoing
    end

    expose :group_admins, with: Pollios::V1::Shared::GroupForAdminListEntity

    expose :recommendations do
      expose_members :recommended_officials, as: :officials, without_linkage: true
      expose_members :recommended_friends, as: :friends, without_linkage: true
      expose_members :recommended_via_facebooks, as: :facebooks, without_linkage: true

      expose_groups :recommended_groups, as: :groups, without_status: true
    end


    def current_member_linkage
      @current_member_linkage ||= Member::MemberList.new(object.member).social_linkage_ids
    end

    def current_member_status
      @current_member_status ||= Member::GroupList.new(object.member).relation_status_ids
    end
  end
end
module Pollios::V1::CurrentMemberAPI
  class RequestCardListEntity < Pollios::V1::BaseEntity

    expose :friends do
      expose_members :friends_incoming, as: :incoming, entity: Pollios::V1::Shared::MemberWithActivityEntity
      expose_members :friends_outgoing, as: :outgoing, entity: Pollios::V1::Shared::MemberWithActivityEntity
    end

    expose :groups do
      expose_groups :group_invitations, as: :incoming, entity: Pollios::V1::Shared::GroupWithLastestMemberEntity
      expose_groups :group_requests, as: :outgoing, entity: Pollios::V1::Shared::GroupWithLastestMemberEntity
    end

    expose :group_admins, with: Pollios::V1::Shared::GroupForAdminListEntity

    expose :recommendations do
      expose_members :recommended_officials, as: :officials, without_linkage: true, entity: Pollios::V1::Shared::MemberWithActivityEntity
      expose_members :recommended_friends, as: :friends, without_linkage: true, entity: Pollios::V1::Shared::MemberWithActivityEntity
      expose_members :recommended_via_facebooks, as: :facebooks, without_linkage: true, entity: Pollios::V1::Shared::MemberWithActivityEntity

      expose_groups :recommended_groups, as: :groups, without_status: true, entity: Pollios::V1::Shared::GroupWithLastestMemberEntity
    end

    def current_member_linkage
      @current_member_linkage ||= Member::MemberList.new(object.member).social_linkage_ids
    end

    def current_member_status
      @current_member_status ||= Member::GroupList.new(object.member).relation_status_ids
    end
  end
end
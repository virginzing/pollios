module Pollios::V1::CurrentMemberAPI
  class RequestListEntity < Pollios::V1::BaseEntity

    expose :group_admins, with: Pollios::V1::Shared::GroupForAdminListEntity

    expose :friends do
      expose :friends_incoming_count, as: :incoming_count
      expose_members :friends_incoming, as: :incoming
      expose :friends_outgoing_count, as: :outgoing_count
      expose_members :friends_outgoing, as: :outgoing
    end

    expose :groups do
      expose :group_incoming_count, as: :incoming_count
      expose_groups :group_incoming, as: :incoming
      expose :group_outgoing_count, as: :outgoing_count
      expose_groups :group_outgoing, as: :outgoing
    end

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

    def request
      object
    end

    def friends_incoming_count
      request.friends_incoming.size
    end

    def friends_incoming
      request.friends_incoming.sample(10)
    end

    def friends_outgoing_count
      request.friends_outgoing.size
    end

    def friends_outgoing
      request.friends_outgoing.sample(10)
    end

    def group_incoming_count
      request.group_invitations.size
    end

    def group_incoming
      request.group_invitations.sample(10)
    end

    def group_outgoing_count
      request.group_requests.size
    end

    def group_outgoing
      request.group_requests.sample(10)
    end
  end
end
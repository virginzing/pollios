module Pollios::V1::GroupAPI
  class MemberListEntity < Pollios::V1::BaseEntity

    expose_members :admins, as: :admin
    expose_members :members, as: :member
    expose_members :requesting
    expose_members :pending

    def current_member_linkage
      @current_member_linkage ||= Member::MemberList.new(current_member).social_linkage_ids
    end

    def requesting
      return object.requesting if viewing_own_group?
      return [current_member] if viewing_requesting_group?
      []
    end

    def current_member
      options[:current_member]  
    end

    def viewing_own_group?
      object.admin?(current_member)
    end

    def viewing_requesting_group?
      object.requesting?(current_member)
    end
  end
end
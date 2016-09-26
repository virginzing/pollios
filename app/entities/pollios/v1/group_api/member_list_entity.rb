module Pollios::V1::GroupAPI
  class MemberListEntity < Pollios::V1::BaseEntity

    expose_members :admins, as: :admin
    expose_members :members, as: :member
    expose_members :requesting
    expose_members :pending, entity: Pollios::V1::GroupAPI::GroupMemberListEntity

    def current_member_linkage
      options[:current_member_linkage]
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
      group_member_inquiry.admin?(current_member)
    end

    def viewing_requesting_group?
      group_member_inquiry.requesting?(current_member)
    end

    def group_member_inquiry
      @group_member_inquiry ||= Group::MemberInquiry.new(object.group)
    end
  end
end
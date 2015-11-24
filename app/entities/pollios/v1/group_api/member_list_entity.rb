module Pollios::V1::GroupAPI
  class MemberListEntity < Pollios::V1::BaseEntity

    expose_members :members_as_admin, as: :admin
    expose_members :members_as_member, as: :member
    expose_members :requesting
    expose_members :pending

    def current_member_linkage
      @current_member_linkage ||= Member::MemberList.new(options[:current_member]).social_linkage_ids
    end
  end
end
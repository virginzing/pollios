module Pollios::V1::SearchAPI
  class MemberAndGroupEntity < Pollios::V1::BaseEntity

    expose_members :members_searched, as: :members
    expose_groups :groups_searched, as: :groups

    def current_member_linkage 
      @current_member_linkage ||= Member::MemberList.new(options[:current_member]).social_linkage_ids
    end
  end
end
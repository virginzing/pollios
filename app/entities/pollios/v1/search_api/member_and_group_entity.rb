module Pollios::V1::SearchAPI
  class MemberAndGroupEntity < Pollios::V1::BaseEntity

    expose_members :first_5_members_searched, as: :members
    expose_groups :first_5_groups_searched, as: :groups

    def current_member_linkage 
      options[:current_member_linkage]
    end

    def current_member_status
      options[:current_member_status]
    end
  end
end
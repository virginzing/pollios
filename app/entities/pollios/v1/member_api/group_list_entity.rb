module Pollios::V1::MemberAPI
  class GroupListEntity < Pollios::V1::BaseEntity
    expose_groups :as_admin, as: :admin_of
    expose_groups :as_member, as: :member_of
    expose_groups :inactive, as: :pending

    def current_member_status
      options[:current_member_status]
    end
  end
end
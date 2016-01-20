module Pollios::V1::MemberAPI
  class GroupListEntity < Pollios::V1::BaseEntity
    expose_groups :as_admin, as: :admin_of
    expose_groups :as_member, as: :member_of
    expose_groups :inactive, as: :pending

    def current_member_status
      @current_member_status ||= Member::GroupList.new(options[:current_member]).relation_status_ids
    end
  end
end
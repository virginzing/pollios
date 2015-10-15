module Pollios::V1::Member
  class GroupListEntity < Grape::Entity
    expose :as_admin, as: :admin_of
    expose :as_member, as: :member_of
    expose :inactive, as: :pending
  end
end
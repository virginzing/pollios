module Pollios::V1::Member
  class GroupListEntity < Grape::Entity
    expose :as_admin, as: :admin_of, with: Pollios::V1::Shared::GroupForListEntity
    expose :as_member, as: :member_of, with: Pollios::V1::Shared::GroupForListEntity
    expose :inactive, as: :pending, with: Pollios::V1::Shared::GroupForListEntity
  end
end
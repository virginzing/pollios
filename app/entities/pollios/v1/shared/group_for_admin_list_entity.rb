module Pollios::V1::Shared
  class GroupForAdminListEntity < Pollios::V1::Shared::GroupEntity
    expose :members_request, as: :request, with: MemberForListEntity
  end
end

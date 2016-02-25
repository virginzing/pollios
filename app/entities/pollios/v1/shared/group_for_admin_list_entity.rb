module Pollios::V1::Shared
  class GroupForAdminListEntity < Pollios::V1::Shared::GroupForListEntity
    expose :members_request, as: :request, with: MemberEntity
  end
end

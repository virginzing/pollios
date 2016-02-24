module Pollios::V1::Shared
  class GroupForAdminListEntity < Pollios::V1::Shared::GroupEntity
    unexpose :admin_post_only
    unexpose :opened
    expose :members_request, as: :request, with: MemberEntity
  end
end

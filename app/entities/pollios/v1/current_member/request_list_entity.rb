module Pollios::V1::CurrentMember
  class RequestListEntity < Pollios::V1::BaseEntity
    expose :incoming_requests
    expose :outgoing_requests
    expose :group_invitations
    expose :group_requests
  end
end
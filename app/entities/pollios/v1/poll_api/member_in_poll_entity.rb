module Pollios::V1::PollAPI
  class MemberInPollEntity < Pollios::V1::Shared::MemberForListEntity

    unexpose :description
    unexpose :status

  end
end
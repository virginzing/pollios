module Pollios::V1::PollAPI
  class MemberVotedDetailEntity < Pollios::V1::Shared::MemberListEntity
    
    expose :anonymous, if: -> (obj, _) { obj.index == 1 }

  end
end
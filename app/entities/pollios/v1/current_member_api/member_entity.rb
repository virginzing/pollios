module Pollios::V1::CurrentMemberAPI
  class MemberEntity < Pollios::V1::Shared::MemberEntity
    
    expose :point
    expose :notification_count
    expose :request_count
    expose :first_signup

  end
end
module Pollios::V1::CurrentMemberAPI
  class MemberEntity < Pollios::V1::Shared::MemberEntity
    
    expose :email
    expose :point
    expose :notification_count
    expose :request_count
    expose :first_signup
    expose :waiting_info

    private

    def waiting_info
      WaitingList.new(object).get_info
    end

  end
end
module Pollios::V1::Shared
  class MemberWithActivityEntity < MemberEntity

    expose :activity, with: ActivityEntity

    def activity
      Member::PollList.new(object).recent_public_activity(3)
    end

  end
end
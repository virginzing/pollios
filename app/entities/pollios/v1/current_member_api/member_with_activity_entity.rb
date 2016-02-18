module Pollios::V1::CurrentMemberAPI
  class MemberWithActivityEntity < Pollios::V1::Shared::MemberForListEntity

    expose :activity, with: PollActivityEntity

    def activity
      Member::PollList.new(object).recent_public_activity(3)
    end

  end
end
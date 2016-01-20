module Pollios::V1::CurrentMemberAPI
  class MemberAccountEntity < Pollios::V1::BaseEntity

    expose :point
    expose :friends
    expose :friends_limit
    expose :sync_facebook

    private

    def member
      object
    end

    def friends
      Member::MemberList.new(member).active.count
    end

    def friends_limit
      Member::FRIEND_LIMIT
    end

  end
end
module Pollios::V1::CurrentMemberAPI
  class SettingAccountEntity < Pollios::V1::BaseEntity

    expose :member_type

    with_options(format_with: :as_integer) do
      expose :subscribe_expire, unless: -> (_, _) { member.citizen? }
    end
    expose :point, if: -> (_, _) { member.citizen? }
    
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
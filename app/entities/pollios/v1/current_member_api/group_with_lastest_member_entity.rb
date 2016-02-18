module Pollios::V1::CurrentMemberAPI
  class GroupWithLastestMemberEntity < Pollios::V1::Shared::GroupEntity

    expose :lastest_member, with: Pollios::V1::Shared::MemberForListEntity

    def lastest_member
      Group::MemberList.new(object).join_recently
    end

  end
end
module Pollios::V1::Shared
  class GroupWithLastestMemberEntity < GroupForListEntity

    expose :admin_post_only
    expose :lastest_member, with: MemberForListEntity

    def lastest_member
      Group::MemberList.new(object).join_recently
    end

  end
end
module Pollios::V1::GroupAPI
  class GroupMemberListEntity < Pollios::V1::Shared::MemberEntity
    
    expose :invited_by do
      expose :member_invite_id, as: :member_id
      expose :inviter_name, as: :name
    end

    def inviter_name
      Member.cached_find(object.member_invite_id).fullname
    end
  end
end
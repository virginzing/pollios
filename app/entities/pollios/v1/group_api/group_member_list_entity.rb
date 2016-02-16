module Pollios::V1::GroupAPI
  class GroupMemberListEntity < Pollios::V1::Shared::MemberEntity
    
    expose :invited_by do
      expose :inviter_id, as: :member_id
      expose :inviter_name, as: :name
    end

    def inviter_name
      Member.cached_find(object.inviter_id).fullname
    end
  end
end
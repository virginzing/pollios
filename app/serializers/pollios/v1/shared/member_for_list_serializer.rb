module Pollios::V1::Shared
  class MemberForListSerializer < Pollios::V1::BaseSerializer
    
    attributes :member_id, :name, :description, :avatar, :type, :status

    def member_id
      object.id
    end

    def name
      object.fullname
    end

    def type
      object.member_type_text
    end

    def status
      object.is_friend(current_member)
    end

    def avatar
      object.get_avatar
    end
  end
end
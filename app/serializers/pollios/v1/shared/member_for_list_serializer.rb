module Pollios::V1::Shared
  class MemberForListSerializer < ActiveModel::Serializer
    delegate :current_member, to: :scope

    attributes :member_id, :fullname, :description, :avatar, :type, :status

    def member_id
      object.id
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
module Pollios::V1::Shared
  class MemberForListSerializer < ActiveModel::Serializer
    delegate :current_member, to: :scope

    attributes :id, :fullname, :avatar, :description, :key_color
    attributes :status

    def status
      object.is_friend(current_member)
    end

    def avatar
      object.get_avatar
    end
  end
end
module Pollios::V1::Shared
  class MemberForListSerializer < ActiveModel::Serializer
    
    include Pollios::V1::Shared::APIHelpers

    delegate :current_member, to: :scope

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
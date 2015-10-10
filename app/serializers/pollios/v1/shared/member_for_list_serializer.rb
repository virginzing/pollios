module Pollios::V1::Shared
  class MemberForListSerializer < ActiveModel::Serializer
    delegate :current_member, to: :scope

    attributes :id, :fullname, :status

    def status
      object.is_friend(current_member)
    end
  end
end
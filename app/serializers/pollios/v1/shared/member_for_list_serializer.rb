module Pollios::V1::Shared
  class MemberForListSerializer < Pollios::V1::BaseSerializer
    
    attributes :member_id, :name, :description, :avatar, :type, :status

    def initialize(object, options = {})
      super(object, options)
      @viewing_member_list = Member::MemberList.new(current_member)
    end

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
      @viewing_member_list.friendship_status_hash_with_member(object)
    end

    def avatar
      object.get_avatar
    end
  end
end
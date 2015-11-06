module Pollios::V1::Shared
  class MemberEntity < Pollios::V1::BaseEntity
    
    expose :id, as: :member_id
    expose :fullname, as: :name
    expose :description
    expose :get_avatar, as: :avatar
    expose :member_type_text, as: :type
    expose :get_key_color, as: :key_color, if: -> (obj, opts) { obj.get_key_color.present? }
    expose :status, if: -> (object, options) { options[:current_member_linkage].present? }

    def self.default_pollios_member
      {
        member_id: 0,
        name: "Pollios System",
        avatar: "http://pollios.com/images/logo/pollios_system_notification.png",
        description: "Pollios Office"
      }
    end

    def status
      relation = options[:current_member_linkage]

      hash = { :status => :nofriend }

      is_friend = relation[:friends_ids].include?(object.id)
      is_requesting = relation[:requesting_ids].include?(object.id)
      is_being_requested = relation[:being_requested_ids].include?(object.id)
      is_blocking = relation[:blocks_ids].include?(object.id)

      if is_friend
        hash[:status] = :friend
      elsif is_requesting
        hash[:status] = :invite
      elsif is_being_requested
        hash[:status] = :invitee
      elsif is_blocking
        hash[:status] = :block
      end

      if object.celebrity? || object.brand? || object.company?
        is_following = relation[:followings_ids].include?(object.id)
        hash[:following] = is_following ? true : false
      end

      hash
    end

  end
end
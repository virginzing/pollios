module Pollios::V1::Shared
  class MemberEntity < Pollios::V1::BaseEntity

    expose :id, as: :member_id
    expose :fullname, as: :name
    expose :description
    expose :get_avatar, as: :avatar
    expose :member_type_text, as: :type
    expose :get_key_color, as: :key_color, if: -> (obj, _) { obj.get_key_color.present? }
    expose :status, if: -> (_, opts) { opts[:current_member_linkage].present? }

    def self.default_pollios_member
      {
        member_id: 0,
        name: 'Pollios System',
        avatar: 'http://pollios.com/images/logo/pollios_system_notification.png',
        description: 'Pollios Office'
      }
    end

    def status
      hash = { status: hash_status }

      if object.celebrity? || object.brand? || object.company?
        relation = options[:current_member_linkage]
        is_following = relation[:followings_ids].include?(object.id)
        hash[:following] = is_following ? true : false
      end

      hash
    end

    private
    def hash_status
      relation = options[:current_member_linkage]
      return :friend if relation[:friends_ids].include?(object.id)
      return :invite if relation[:requesting_ids].include?(object.id)
      return :invitee if relation[:being_requested_ids].include?(object.id)
      return :block if relation[:blocks_ids].include?(object.id)

      :nofriend
    end

  end
end
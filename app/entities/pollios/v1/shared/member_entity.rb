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

    private

    def status
      hash = {}
      hash[:status] = friendship_status_with_current_member
      hash[:following] = following? if followable_member?
      hash
    end

    def friendship_status_with_current_member
      return :friend if friend?
      return :invite if requesting?
      return :invitee if being_requested?
      return :block if blocked?
      :nofriend
    end

    def followable_member?
      object.celebrity? || object.brand? || object.company?
    end

    def relation
      options[:current_member_linkage]
    end

    def friend?
      relation[:friends_ids].include?(object.id)
    end

    def following?
      relation[:followings_ids].include?(object.id)
    end

    def requesting?
      relation[:requesting_ids].include?(object.id)
    end

    def being_requested?
      relation[:being_requested_ids].include?(object.id)
    end

    def blocked?
      relation[:blocks_ids].include?(object.id)
    end
  end
end
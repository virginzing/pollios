module Pollios::V1::Shared
  class MemberEntity < Pollios::V1::BaseEntity

    expose :id, as: :member_id
    expose :fullname, as: :name
    expose :description
    expose :get_avatar, as: :avatar
    expose :get_cover_image, as: :cover, if: -> (obj, _) { obj.get_cover_image.present? }
    expose :get_cover_preset, as: :cover_preset, unless: -> (obj, _) { obj.get_cover_image.present? }
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
      hash[:following] = followings? if followable_member?
      hash
    end

    def friendship_status_with_current_member
      return :friend if friends?
      return :invite if requesting?
      return :invitee if being_requested?
      return :block if blocks?
      :nofriend
    end

    def followable_member?
      object.celebrity? || object.brand? || object.company?
    end

    def relation
      options[:current_member_linkage]
    end

    def friends?
      relation[:friends_ids].include?(object.id)
    end

    def followings?
      relation[:followings_ids].include?(object.id)
    end

    def requesting?
      relation[:requesting_ids].include?(object.id)
    end

    def being_requested?
      relation[:being_requested_ids].include?(object.id)
    end

    def blocks?
      relation[:blocks_ids].include?(object.id)
    end

    # Could use some metaprogramming. This actually works.
    #
    # def relation_lists
    #   %('friends', 'followings', 'requesting', 'being_requested', 'blocks')
    # end

    # relation_lists.each do |list_name|
    #   define_method("#{list_name}?") do 
    #     relation["#{list_name}_ids".to_sym].include?(object.id)
    #   end
    # end
  end
end
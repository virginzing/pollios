module Pollios::V1::Shared
  class MemberForListEntity < Pollios::V1::Shared::MemberEntity

    unexpose :get_cover_image
    unexpose :get_cover_preset
    unexpose :get_key_color

    expose :invited_by, if: -> (obj, _) { obj.has_attribute?(:member_invite_id) && obj.member_invite_id.present? } do |_, _|
      MemberForListEntity.represent invited_by, only: [:member_id, :name, :avatar]
    end

    def invited_by
      Member.cached_find(object.member_invite_id)
    end

  end
end
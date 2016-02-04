module Pollios::V1::Shared
  class MemberForListEntity < Pollios::V1::Shared::MemberEntity

    unexpose :get_cover_image
    unexpose :get_cover_preset
    unexpose :member_type_text
    unexpose :get_key_color

  end
end
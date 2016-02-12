module Pollios::V1::Shared
  class PollForListEntity < Pollios::V1::Shared::PollDetailEntity

    unexpose :get_choice_detail
    unexpose :choice_count
    unexpose :get_original_images
    unexpose :thumbnail_type

  end
end
module Pollios::V1::Shared
  class PollForListEntity < Pollios::V1::Shared::PollDetailEntity

    unexpose :get_choice_detail
    unexpose :choice_count
    unexpose :public
    unexpose :get_creator_must_vote
    unexpose :get_original_images

  end
end
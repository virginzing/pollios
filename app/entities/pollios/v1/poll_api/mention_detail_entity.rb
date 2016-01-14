module Pollios::V1::PollAPI
  class MentionDetailEntity < Pollios::V1::BaseEntity

    expose :mentionable_id, as: :member_id
    expose :mentionable_name, as: :name

  end
end
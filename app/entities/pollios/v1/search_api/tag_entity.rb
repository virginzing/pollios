module Pollios::V1::SearchAPI
  class TagEntity < Pollios::V1::BaseEntity

    expose :id, as: :tag_id
    expose :name
    expose :count

  end
end
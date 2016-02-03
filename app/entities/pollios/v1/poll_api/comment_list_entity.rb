module Pollios::V1::PollAPI
  class CommentListEntity < Pollios::V1::BaseEntity

    expose :next_index
    expose :comments, with: CommentDetailEntity

  end
end
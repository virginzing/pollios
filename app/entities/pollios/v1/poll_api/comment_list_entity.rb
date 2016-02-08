module Pollios::V1::PollAPI
  class CommentListEntity < Pollios::V1::BaseEntity

    expose :next_index
    expose :comment_count, if: -> (obj, _) { obj.index == 1 }
    expose :comments_by_page, as: :comments, with: CommentDetailEntity

  end
end
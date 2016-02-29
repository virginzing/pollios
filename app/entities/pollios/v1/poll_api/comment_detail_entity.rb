module Pollios::V1::PollAPI
  class CommentDetailEntity < Pollios::V1::BaseEntity

    expose :id, as: :comment_id
    expose :message
    with_options(format_with: :as_integer) do
      expose :created_at
    end
    expose :mentions, if: -> (obj, _) { obj.mentions.present? }, with: MentionDetailEntity
    expose :report_count
    expose :creator, with: MemberInPollEntity

    def creator
      object.member
    end

  end
end
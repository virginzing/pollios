module Pollios::V1::PollAPI
  class CommentDetailEntity < Pollios::V1::BaseEntity

    expose :id, as: :comment_id
    expose :message
    expose :mentions, if: -> (obj, _) { obj.mentions.present? }, with: MentionDetailEntity
    expose :report_count
    expose_members :creator

    def comment
      object
    end

    def creator
      comment.member
    end

    def current_member_linkage
      @current_member_linkage ||= Member::MemberList.new(options[:current_member]).social_linkage_ids
    end

  end
end
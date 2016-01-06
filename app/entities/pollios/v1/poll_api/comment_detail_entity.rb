module Pollios::V1::PollAPI
  class CommentDetailEntity < Pollios::V1::BaseEntity

    expose :id
    expose :message
    expose :report_count
    expose_members :creator

    def comment
      object
    end

    def creator
      Member.cached_find(comment.member_id)
    end

    def current_member_linkage
      @current_member_linkage ||= Member::MemberList.new(options[:current_member]).social_linkage_ids
    end

  end
end
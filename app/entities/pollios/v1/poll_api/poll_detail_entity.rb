module Pollios::V1::PollAPI
  class PollDetailEntity < Pollios::V1::BaseEntity

    expose :creator do |obj, opts|
      Pollios::V1::Shared::MemberEntity.represent creator, current_member_linkage: current_member_linkage
    end

    def creator
      Member.cached_find(object.member_id)
    end

    def current_member_linkage
      @current_member_linkage ||= Member::MemberList.new(options[:current_member]).social_linkage_ids
    end
  end
end
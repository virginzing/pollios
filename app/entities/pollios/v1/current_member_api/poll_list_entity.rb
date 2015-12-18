module Pollios::V1::CurrentMemberAPI
  class PollListEntity < Pollios::V1::BaseEntity
    expose :bookmarkeds, as: :bookmarks, with: Pollios::V1::Shared::PollDetailEntity

    def current_member_linkage
      @current_member_linkage ||= Member::MemberList.new(current_member).social_linkage_ids
    end

    def current_member
      options[:current_member]  
    end
  end
end
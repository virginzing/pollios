module Pollios::V1::PollAPI
  class MemberVotedDetailEntity < Pollios::V1::BaseEntity
    
    expose :anonymous
    expose_members :voter, entity: Pollios::V1::Shared::MemberForListEntity

    def current_member_linkage
      @current_member_linkage ||= Member::MemberList.new(options[:current_member]).social_linkage_ids
    end

  end
end
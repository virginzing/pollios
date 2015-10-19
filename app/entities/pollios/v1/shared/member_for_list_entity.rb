module Pollios::V1::Shared
  class MemberForListEntity < Pollios::V1::Shared::MemberEntity

    expose :status

    def status
      relation = options[:current_member_linkage]

      hash = {:status => :nofriend}

      is_friend = relation[:friends_ids].include?(object.id)
      is_requesting = relation[:requesting_ids].include?(object.id)
      is_being_requested = relation[:being_requested_ids].include?(object.id)
      is_blocking = relation[:blocks_ids].include?(object.id)

      if is_friend
        hash[:status] = :friend
      elsif is_requesting
        hash[:status] = :invite
      elsif is_being_requested
        hash[:status] = :invitee
      elsif is_blocking
        hash[:status] = :block
      end

      if object.celebrity? || object.brand? || object.company?
        is_following = relation[:followings_ids].include?(object.id)
        hash[:following] = is_following ? true : false
      end

      hash
    end
  end
end
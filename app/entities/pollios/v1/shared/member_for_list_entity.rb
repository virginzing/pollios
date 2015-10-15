module Pollios::V1::Shared
  class MemberForListEntity < Grape::Entity

    expose :id, as: :member_id
    expose :fullname, as: :name
    expose :description
    expose :get_avatar, as: :avatar
    expose :member_type_text, as: :type

    expose :status


    def status
      current_member_linkage = options[:current_member_linkage]

      hash = {:add_friend_already => false, :status => :nofriend, :following => "" }

      is_friend = current_member_linkage[:friends_ids].include?(object.id)
      is_requesting = current_member_linkage[:requesting_ids].include?(object.id)
      is_being_requested = current_member_linkage[:being_requested_ids].include?(object.id)
      is_blocking = current_member_linkage[:blocks_ids].include?(object.id)


      if is_friend || is_requesting || is_being_requested || is_blocking
        hash[:add_friend_already] = true
      end

      if is_friend
        hash[:status] = :friend
      elsif is_requesting
        hash[:status] = :invite
      elsif is_being_requested
        hash[:status] = :invitee
      elsif is_blocking
        hash[:status] = :block
      end

      if object.celebrity? || object.brand?
        is_following = current_member_linkage[:followings_ids].include?(object.id)
        hash[:following] = is_following ? true : false
      end

      hash
    end
  end
end
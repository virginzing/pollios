class Member::Recommendation

  attr_reader :member

  def initialize(member)
    @member = member
  end

  def member_listing
    @member_listing ||= Member::MemberList.new(member)
  end

  def group_listing
    @group_listing ||= Member::GroupList.new(member)
  end

  def groups
    suggest_group_ids = SuggestGroup.cached_all.map(&:id)

    recommend_group_ids = suggest_group_ids - mebmer_have_relation_group_ids

    Group.find(recommend_group_ids)
  end

  def officials
    followings_ids = member_listing.followings.map(&:id)
    
    Member.where('((member_type = 1) OR (member_type = 3 AND show_recommend = true)) AND id NOT IN (?)' \
      , followings_ids | blocks_ids | friends_ids | unrecomment_ids | [member.id])
      .order('created_at desc')
      .limit(500)
  end

  def facebooks
    return [] unless friends_ids.count > 0

    member_using_facebook = Member.where('status_account = 1 AND member_type = 0')
                            .where(fb_id: member.list_fb_id, first_signup: false)

    member_using_facebook.where('id NOT IN (?)', friends_ids)
  end

  def friends
    Member.where('status_account = 1 AND member_type = 0 AND id IN (?) AND id NOT IN (?)' \
      , mutual_friends_ids | mutual_group_ids | most_friends_ids\
      , facebooks.map(&:id) | mebmer_have_relation_member_ids | unrecomment_ids | [member.id])
  end

  def mutual_friends_ids
    return [] unless friends_ids.count > 0

    Friend.select('followed_id').where('status = 1 AND follower_id IN (?)', friends_ids)
      .group('followed_id')
      .map(&:followed_id)
  end

  def mutual_group_ids
    return [] unless group_listing.active.count > 0

    member_from_mutual_group_ids = group_listing.active.collect { |group| Group::MemberList.new(group).active.map(&:id) } \
                                   .flatten.uniq

    member_from_mutual_group_ids - friends_ids
  end

  def most_friends_ids
    most_friends_ids = Friend.select('follower_id, count(follower_id) as freinds_count')
                       .where('status = 1')
                       .group('follower_id')
                       .order('freinds_count desc')
                       .map(&:follower_id)
    most_friends_ids - friends_ids
  end

  def friends_ids
    @friends_ids ||= member_listing.active.map(&:id)
  end

  def blocks_ids
    @blocks_ids ||= member_listing.blocks.map(&:id)
  end

  def unrecomment_ids
    @unrecomment_ids ||= member.cached_get_unrecomment.map(&:unrecomment_id)
  end

  def mebmer_have_relation_group_ids
    @member_relation_status_ids ||= group_listing.relation_status_ids.values.flatten
  end

  def mebmer_have_relation_member_ids
    @member_relation_status_ids ||= member_listing.social_linkage_ids.values.flatten
  end

end
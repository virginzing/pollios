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
    member_relation_status_ids = group_listing.relation_status_ids.values

    mebmer_have_relation_group_ids  = []
    member_relation_status_ids.each { |relation| relation.each { |id| mebmer_have_relation_group_ids << id } }

    recommend_group_ids = suggest_group_ids - mebmer_have_relation_group_ids

    Group.find(recommend_group_ids)
  end

  def officials
    followings_ids = member_listing.followings.map(&:id)
    blocks_ids = member_listing.blocks.map(&:id)
    unrecomment_ids = member.cached_get_unrecomment.map(&:unrecomment_id)


    Member.where('((member_type = 1) OR (member_type = 3 AND show_recommend = true)) AND id NOT IN (?)' \
      , followings_ids | blocks_ids | friends_ids | unrecomment_ids | [member.id])
      .order('created_at')
      .limit(500)
  end

  def facebooks
    member_using_facebook = Member.where('status_account = 1 AND member_type = 0') \
                            .where(fb_id: member.list_fb_id, first_signup: false)

    member_using_facebook.where('id NOT IN (?)', friends_ids) if friends_ids.count > 0
  end

  def friends_ids
    member_listing.active.map(&:id)
  end

end
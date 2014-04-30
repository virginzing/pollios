class HashtagTimeline
  def initialize(member_obj, options)
    @member = member_obj
    @options = options
    @hidden_poll = HiddenPoll.my_hidden_poll(member_obj.id)
  end

  def member_id
    @member.id
  end

  def query_tag
    @options["name"]
  end

  def your_friend_ids
    @friend_ids ||= @member.whitish_friend.map(&:followed_id) << member_id
  end

  def your_group
    @member.get_group_active
  end

  def your_group_ids
    your_group.map(&:id)
  end

  def group_by_name
    Hash[your_group.map{ |f| [f.id, Hash["id" => f.id, "name" => f.name, "photo" => f.get_photo_group, "member_count" => f.member_count, "poll_count" => f.poll_count]] }]
  end

  def get_hashtag
    @hashtag ||= tag_friend_group_public
  end

  def get_hashtag_popular
    @hashtag_popular ||= tag_popular.map(&:name)
  end


  private

  def tag_popular
    Tag.joins(:taggings => [:poll => :poll_members]).
      where("(polls.public = ?) OR (poll_members.member_id IN (?) AND poll_members.share_poll_of_id = 0)", true, your_friend_ids).
      select("tags.*, count(taggings.tag_id) as count").
      group("taggings.tag_id, tags.id").
      order("count desc").limit(5)
  end

  def tag_friend_group_public
    Tag.find_by_name(query_tag).polls.
    joins(:poll_members).
    includes(:poll_groups, :campaign, :choices, :member).
    order('polls.created_at desc, polls.vote_all desc, polls.public desc, polls.expire_date desc').
    where("(polls.public = ?) OR (poll_members.member_id IN (?) AND poll_members.in_group = ? AND poll_members.share_poll_of_id = 0) " \
          "OR (poll_groups.group_id IN (?))", true, your_friend_ids, false, your_group_ids).references(:poll_groups)
  end


  
  
end
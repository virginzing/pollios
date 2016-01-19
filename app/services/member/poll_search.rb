class Member::PollSearch

  attr_reader :member, :hashtag

  def initialize(member, hashtag = nil)
    @member = member

    return unless hashtag
    @hashtag = hashtag.downcase

    save_recent_tag
  end

  def recent
    recent_tags
  end

  def popular
    popular_tags
  end

  def polls_searched
    search_polls
  end

  def recent_tags
    TypeSearch.find_by(member_id: member.id)[:search_tags].map { |tag| tag[:message] }.uniq[0..9]
  end

  def popular_tags
    Tag.joins('LEFT OUTER JOIN taggings ON tags.id = taggings.tag_id')
      .joins('LEFT OUTER JOIN polls ON taggings.poll_id = polls.id')
      .where("polls.expire_status = 'f' AND polls.vote_all > 0 AND polls.in_group = 'f' AND polls.series = 'f'")
      .select('tags.*, count(taggings.tag_id) as count')
      .select('tags.*, max(taggings.created_at) AS tagged')
      .group('tags.id')
      .order('count desc, tagged desc')
      .limit(10)
  end

  def search_polls
    Poll.viewing_by_member(member)
      .joins('LEFT OUTER JOIN taggings ON polls.id = taggings.poll_id')
      .joins('LEFT OUTER JOIN tags ON taggings.tag_id = tags.id')
      .where('LOWER(tags.name) = (?)', hashtag)
  end

  def save_recent_tag
    recent_search = TypeSearch.find_by(member_id: member.id)
    recent_search.update!(search_tags: TypeSearch.find_by(member_id: member.id)[:search_tags] \
      .unshift(message: hashtag, created_at: Time.now.utc))
  end

end
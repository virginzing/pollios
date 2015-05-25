class Admin::BanMember

  def self.cached_member_ids
    Rails.cache.fetch("ban_members") { get_member_ids }  
  end

  def self.get_member_ids
    Member.with_status_account(:ban).map(&:id)
  end

  def self.flush_cached_ban_members
    Rails.cache.delete("ban_members")
  end

end
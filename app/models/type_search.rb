class TypeSearch
  include Mongoid::Document
  include Mongoid::Attributes::Dynamic
  include Mongoid::Timestamps

  field :search_tags, type: Array
  field :search_users, type: Array

  index({ member_id: 1}, { unique: true, name: "member_id_type_search_index"})

  def self.create_log_search_tags(member, message)
    @member = member
    @search_log = member_find_create_log

    old_search_tag = @search_log.search_tags
    hash_search_tag = {
      message: message,
      created_at: Time.zone.now
    }

    new_search_tag = old_search_tag.insert(0, hash_search_tag)

    @search_log.update!(search_tags: new_search_tag)
  end


  def self.create_log_search_users(member, message)
    @member = member
    @search_log = member_find_create_log

    old_search_users = @search_log.search_users
    hash_search_user = {
      message: message,
      created_at: Time.zone.now
    }
    
    new_search_user = old_search_users.insert(0, hash_search_user)

    @search_log.update!(search_users: new_search_user)
  end

  def self.member_find_create_log
    member_search_log = find_by(member_id: @member.id)

    unless member_search_log.present?
      member_search_log = create!(member_id: @member.id, search_tags: [], search_users: [])
    end

    member_search_log
  end

end
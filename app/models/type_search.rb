class TypeSearch
  include Mongoid::Document
  include Mongoid::Attributes::Dynamic
  include Mongoid::Timestamps

  field :search_tags, type: Array
  field :search_users_and_groups, type: Array

  index({ member_id: 1}, { unique: true, name: "member_id_type_search_index"})

  def self.create_log_search_tags(member, message)
    @member = member
    @search_log = member_find_create_log
    old_search_tag = @search_log.search_tags

    delete_current_message = old_search_tag.select{|e| e if e["message"] != message }

    hash_search_tag = {
      message: message,
      created_at: Time.zone.now
    }

    new_search_tag = delete_current_message.insert(0, hash_search_tag)

    @search_log.update!(search_tags: new_search_tag)
  end


  def self.create_log_search_users_and_groups(member, message)
    @member = member
    @search_log = member_find_create_log

    old_search_users_and_groups = @search_log.search_users_and_groups

    delete_current_message = old_search_users_and_groups.select{|e| e if e["message"] != message }

    hash_search_users_and_groups = {
      message: message,
      created_at: Time.zone.now
    }
    
    new_search_users_and_groups = delete_current_message.insert(0, hash_search_users_and_groups)

    @search_log.update!(search_users_and_groups: new_search_users_and_groups)
  end

  def self.member_find_create_log
    member_search_log = find_by(member_id: @member.id)

    unless member_search_log.present?
      member_search_log = create!(member_id: @member.id, search_tags: [], search_users_and_groups: [])
    end

    member_search_log
  end

  def self.find_search_users_and_groups(member)
    @member = member
    member_find_create_log["search_users_and_groups"].collect{|e| e["message"] }.uniq[0..9]
  end

  def self.find_search_tags(member)
    @member = member
    member_find_create_log["search_tags"].collect{|e| e["message"] }.uniq[0..9]
  end

end
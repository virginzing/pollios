class CountNotification
  def initialize(list_member)
    @list_member = list_member
    @hash_list_member_badge = {}
    @hash_list_member_request_count = {}
    @get_hash_list_member_badge_count = {}
  end

  def device_ids
    @list_member.flat_map {|u| u.apn_devices.map(&:id) }
  end

  def member_ids
    @list_member.flat_map {|u| u.apn_devices.map(&:member_id) }
  end

  def get_hash_list_member_badge_count
    @list_member.each do |member|
      @get_hash_list_member_badge_count.merge!( { member.id => member.notification_count } )
    end
    @get_hash_list_member_badge_count
  end

  def hash_list_member_badge
    @list_member.each do |member|
      member.update_columns(notification_count: member.notification_count + 1)
      @hash_list_member_badge.merge!( { member.id => member.notification_count } )
    end
    @hash_list_member_badge
  end

  def hash_list_member_request_count
    @list_member.each do |member|
      member.update_columns(request_count: member.request_count + 1)
      @hash_list_member_request_count.merge!( { member.id => member.request_count } )
    end
    @hash_list_member_request_count
  end


end

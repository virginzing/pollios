class AddFollowWorker
  include Sidekiq::Worker
  include SymbolHash

  sidekiq_options unique: true

  def perform(member_id, friend_id, options = {})
    member = Member.cached_find(member_id)
    friend = Member.cached_find(friend_id)

    action = options['action']

    @following = Apn::FollowMember.new(member, friend)

    @count_notification = @following.count_notification

    find_recipient ||= Member.where(id: friend_id).uniq

    device_ids = find_recipient.flat_map { |u| u.apn_devices.map(&:id) }

    @custom_properties = {
      type: TYPE[:friend],
      member_id: member_id
    }

    hash_custom = {
      action: action,
      follower_id: member.id,
      followed_id: friend.id,
      worker: WORKER[:add_follow]
    }

    device_ids.each do |device_id|
      @notf = Apn::Notification.new
      @notf.device_id = device_id
      @notf.badge = @count_notification
      @notf.alert = @following.custom_message
      @notf.sound = true
      @notf.custom_properties = @custom_properties
      @notf.save!
    end

    find_recipient.each do |recipient|
      NotifyLog.create(sender_id: member_id, recipient_id: recipient.id, message: @following.custom_message, custom_properties: @custom_properties.merge!(hash_custom))
    end

    Apn::App.first.send_notifications
  rescue => e
    puts "AddFollowWorker => #{e.message}"
  end
end
class AddFriendWorker
  include Sidekiq::Worker
  include SymbolHash
  
  def perform(member_id, friend_id, options = {})
    action = options[:action]

    @add_friend = AddFriend.new(member_id, friend_id, options)

    recipient_id = @add_friend.recipient_id

    find_recipient ||= Member.where(id: recipient_id)

    device_ids = find_recipient.collect {|u| u.apn_devices.collect(&:id)}.flatten

    @custom_properties = { 
      type: TYPE[:friend],
      member_id: member_id
    }

    hash_custom = {
      type: TYPE[:friend],
      action: action
    }

    device_ids.each do |device_id|
      @notf = Apn::Notification.new
      @notf.device_id = device_id
      @notf.badge = 1
      @notf.alert = @add_friend.custom_message
      @notf.sound = true
      @notf.custom_properties = @custom_properties
      @notf.save!
    end

    find_recipient.each do |member|
      NotifyLog.create(sender_id: member_id, recipient_id: member.id, message: @add_friend.custom_message, custom_properties: @custom_properties.merge!(hash_custom))
    end

    Apn::App.first.send_notifications
  end
  
  
end
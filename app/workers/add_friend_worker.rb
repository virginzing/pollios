class AddFriendWorker
  include Sidekiq::Worker
  include SymbolHash

  sidekiq_options unique: true

  def perform(member_id, friend_id, options = {})
    begin
      member = Member.find(member_id)
      friend = Member.find(friend_id)

      member_id = member.id

      action = options["action"]

      @add_friend = AddFriend.new(member, friend, options)

      recipient_id = @add_friend.recipient_id

      @notification_count = @add_friend.count_notification
      
      @request_count = @add_friend.count_request

      find_recipient ||= Member.where(id: recipient_id).uniq

      device_ids = find_recipient.collect {|u| u.apn_devices.collect(&:id)}.flatten

      if action == "BecomeFriend"
        @custom_properties = {
          type: TYPE[:friend],
          member_id: member_id,
          notify: @notification_count
        }
      else
        @custom_properties = {
          type: TYPE[:friend],
          member_id: member_id,
          notify: @notification_count,
          request: @request_count 
        }
      end

      hash_custom = {
        action: action
      }

      device_ids.each do |device_id|
        @notf = Apn::Notification.new
        @notf.device_id = device_id
        @notf.badge = @notification_count
        @notf.alert = @add_friend.custom_message
        @notf.sound = true
        @notf.custom_properties = @custom_properties
        @notf.save!
      end

      find_recipient.each do |member|
        NotifyLog.create(sender_id: member_id, recipient_id: member.id, message: @add_friend.custom_message, custom_properties: @custom_properties.merge!(hash_custom))
      end

      Apn::App.first.send_notifications
    rescue => e
      puts "AddFriendWorker => #{e.message}"
    end
  end


end

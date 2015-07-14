class AddFriendWorker
  include Sidekiq::Worker
  include SymbolHash

  sidekiq_options unique: true

  def perform(member_id, friend_id, options = {})
    # begin
      member = Member.cached_find(member_id)
      friend = Member.cached_find(friend_id)

      member_id = member.id

      action = options["action"]

      @add_friend = AddFriend.new(member, friend, options)

      recipient_id = @add_friend.recipient_id

      @notification_count = @add_friend.count_notification

      @request_count = @add_friend.count_request

      find_recipient ||= Member.where(id: recipient_id).uniq

      receive_notification ||= Member.where(id: @add_friend.receive_notification).uniq

      device_ids = receive_notification.flat_map { |u| u.apn_devices.map(&:id) }

      @custom_properties = {
        type: TYPE[:friend],
        member_id: member_id,
        notify: @notification_count
      }

      hash_custom = {
        action: action,
        friend_id: friend.id,
        worker: WORKER[:add_friend]
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

class GroupNotificationWorker
  include Sidekiq::Worker
  include SymbolHash

  def perform(member, group, poll, custom_data = nil)

    @group_nofication = GroupNotification.new(member, group, poll)

    recipient_ids = @group_nofication.recipient_ids

    find_recipient ||= Member.where(id: recipient_ids)

    device_ids = find_recipient.collect {|u| u.apn_devices.collect(&:id)}.flatten

    @custom_properties = { 
      poll_id: poll.id
    }

    hash_custom = {
      group: group.as_json(), 
      type: TYPE[:poll],
      action: ACTION[:create],
      poll: PollSerializer.new(poll).as_json()
    }

    device_ids.each do |device_id|
      @notf = Apn::Notification.new
      @notf.device_id = device_id
      @notf.badge = 1
      @notf.alert = @group_nofication.custom_message
      @notf.sound = true
      @notf.custom_properties = @custom_properties
      @notf.save!
    end

    find_recipient.each do |member_receive|
      NotifyLog.create(sender_id: member_id, recipient_id: member_receive.id, message: @group_nofication.custom_message, custom_properties: @custom_properties.merge!(hash_custom))
    end

    Apn::App.first.send_notifications
  end

end
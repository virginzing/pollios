class JoinGroupWorker
  include Sidekiq::Worker
  include SymbolHash

  def perform(member, group, custom_data = nil)

    @group_nofication = AskJoinGroup.new(member, group, nil, "join")

    recipient_ids = @group_nofication.recipient_ids

    find_recipient ||= Member.where(id: recipient_ids)

    device_ids = find_recipient.collect {|u| u.apn_devices.collect(&:id)}.flatten

    @custom_properties = { 
      group_id: group.id
    }

    hash_custom = {
      type: TYPE[:group],
      action: ACTION[:join],
      group: group.as_json()
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
      NotifyLog.create(sender_id: member.id, recipient_id: member_receive.id, message: @group_nofication.custom_message, custom_properties: @custom_properties.merge!(hash_custom))
    end

    Apn::App.first.send_notifications
  end

end


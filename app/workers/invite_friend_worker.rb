class InviteFriendWorker
  include Sidekiq::Worker
  include SymbolHash

  def perform(member_id, friend_ids, group_id, custom_data = nil)
    member = Member.find(member_id)
    group = Group.find(group_id)
    
    member_id = member.id

    @invite_group = InviteGroup.new(member_id, friend_ids, group)

    recipient_ids = @invite_group.recipient_ids

    find_recipient ||= Member.where(id: recipient_ids)

    device_ids = find_recipient.collect {|u| u.apn_devices.collect(&:id)}.flatten

    @custom_properties = { 
      group_id: group.id
    }

    hash_custom = {
      type: TYPE[:group],
      action: ACTION[:invite],
      group: group.as_json()
    }

    device_ids.each do |device_id|
      @notf = Apn::Notification.new
      @notf.device_id = device_id
      @notf.badge = 1
      @notf.alert = @invite_group.custom_message
      @notf.sound = true
      @notf.custom_properties = @custom_properties
      @notf.save!
    end

    find_recipient.each do |member|
      NotifyLog.create(sender_id: member_id, recipient_id: member.id, message: @invite_group.custom_message, custom_properties: @custom_properties.merge!(hash_custom))
    end

    Apn::App.first.send_notifications
  end

end


class VotePollWorker
  include Sidekiq::Worker
  include SymbolHash

  def perform(member, poll, custom_data = {})

    member_id = member.id
    
    @apn_poll = Apn::VotePoll.new(member, poll)

    recipient_ids = @apn_poll.recipient_ids

    find_recipient ||= Member.where(id: recipient_ids)

    device_ids = find_recipient.collect {|u| u.apn_devices.collect(&:id)}.flatten

    @custom_properties = { 
      poll_id: poll.id
    }

    hash_custom = {
      anonymous: member.anonymous,
      type: TYPE[:poll],
      action: ACTION[:vote]
    }

    device_ids.each do |device_id|
      @notf = Apn::Notification.new
      @notf.device_id = device_id
      @notf.badge = 1
      @notf.alert = @apn_poll.custom_message
      @notf.sound = true
      @notf.custom_properties = @custom_properties
      @notf.save!
    end

    find_recipient.each do |member|
      NotifyLog.create(sender_id: member_id, recipient_id: member.id, message: @apn_poll.custom_message, custom_properties: @custom_properties.merge!(hash_custom))
    end

    Apn::App.first.send_notifications
  end

end
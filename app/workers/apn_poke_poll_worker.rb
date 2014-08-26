class ApnPokePollWorker
  include Sidekiq::Worker
  include SymbolHash

  def perform(sender_id, list_member, poll_id, custom_data = {})
    poll = Poll.find_by(id: poll_id)

    @apn_poke_poll = Apn::PokePoll.new(poll)

    find_recipient ||= Member.where(id: list_member)

    device_ids = find_recipient.collect {|u| u.apn_devices.collect(&:id)}.flatten

    @custom_properties = { 
      poll_id: poll.id
    }

    hash_custom = {
      type: TYPE[:poll],
      action: ACTION[:create],
      poll: PollSerializer.new(poll).as_json(),
    }

    device_ids.each do |device_id|
      @notf = Apn::Notification.new
      @notf.device_id = device_id
      @notf.badge = 1
      @notf.alert = @apn_poke_poll.custom_message
      @notf.sound = true
      @notf.custom_properties = @custom_properties
      @notf.save!
    end

    find_recipient.each do |member|
      NotifyLog.create(sender_id: sender_id, recipient_id: member.id, message: @apn_poke_poll.custom_message, custom_properties: @custom_properties.merge!(hash_custom))
    end

    Apn::App.first.send_notifications
  end
  
end
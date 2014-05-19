class VotePollWorker
  include Sidekiq::Worker

  def perform(member_id, poll, custom_data = {})
    @apn_poll = Apn::VotePoll.new(member_id, poll)

    recipient_id = @apn_poll.recipient_id

    device_ids = Member.where(id: recipient_id).collect {|u| u.apn_devices.collect(&:id)}.flatten

    device_ids.each do |device_id|
      @notf = Apn::Notification.new
      @notf.device_id = device_id
      @notf.badge = 1
      @notf.alert = @apn_poll.custom_message
      @notf.sound = true
      @notf.custom_properties = { poll_id: poll.id }
      @notf.save!
    end

    Apn::App.first.send_notifications
  end
  
  
end
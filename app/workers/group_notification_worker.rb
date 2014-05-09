class GroupNotificationWorker
  include Sidekiq::Worker

  def perform(member_id, group_id, poll, custom_data = nil)

    @group_nofication = GroupNotification.new(member_id, group_id, poll)

    recipient_ids = @group_nofication.recipient_ids
    puts "ids => #{recipient_ids}"
    device_ids = Member.where(id: recipient_ids).collect {|u| u.apn_devices.collect(&:id)}.flatten

    device_ids.each do |device_id|
      @notf = Apn::Notification.new
      @notf.device_id = device_id
      @notf.badge = 1
      @notf.alert = @group_nofication.custom_message
      @notf.sound = true
      @notf.custom_properties = { poll_id: poll.id }
      @notf.save!
    end
    Apn::App.first.send_notifications
  end

end
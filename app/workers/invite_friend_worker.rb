class InviteFriendWorker
  include Sidekiq::Worker

  def perform(member_id, friend_ids, group, custom_data = nil)

    @invite_group = InviteGroup.new(member_id, friend_ids, group)

    recipient_ids = @invite_group.recipient_ids

    device_ids = Member.where(id: recipient_ids).collect {|u| u.apn_devices.collect(&:id)}.flatten

    device_ids.each do |device_id|
      @notf = Apn::Notification.new
      @notf.device_id = device_id
      @notf.badge = 1
      @notf.alert = @invite_group.custom_message
      @notf.sound = true
      @notf.custom_properties = { friend: true }
      @notf.save!
    end
    Apn::App.first.send_notifications
  end

end
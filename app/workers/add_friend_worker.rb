class AddFriendWorker
  include Sidekiq::Worker

  def perform(member_id, friend_id, opitons = {})

    @add_friend = AddFriend.new(member_id, friend_id, opitons)

    recipient_id = @add_friend.recipient_id

    device_ids = Member.where(id: recipient_id).collect {|u| u.apn_devices.collect(&:id)}.flatten

    device_ids.each do |device_id|
      @notf = Apn::Notification.new
      @notf.device_id = device_id
      @notf.badge = 1
      @notf.alert = @add_friend.custom_message
      @notf.sound = true
      @notf.custom_properties = { friend: true }
      @notf.save!
    end
    Apn::App.first.send_notifications
  end
  
  
end
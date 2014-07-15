class CommentPollWorker
  include Sidekiq::Worker
  include SymbolHash

  def perform(member, poll, custom_data = {})
    comment_message = custom_data[:comment_message]

    member_id = member.id
    
    @apn_comment = Apn::CommentPoll.new(member, poll, comment_message)

    recipient_ids = @apn_comment.recipient_ids

    find_recipient ||= Member.where(id: recipient_ids)

    find_recipient_notify ||= Member.where(id: recipient_ids - [member_id])

    # puts "#{find_recipient_notify.to_a}"
    # device_ids = find_recipient_notify.collect {|u| u.apn_devices.collect(&:id)}.flatten

    @custom_properties = { 
      poll_id: poll.id
    }

    hash_custom = {
      type: TYPE[:comment],
      action: ACTION[:comment],
      poll: PollSerializer.new(poll).as_json(),
      comment: comment_message 
    }

    # device_ids.each do |device_id|
    #   @notf = Apn::Notification.new
    #   @notf.device_id = device_id
    #   @notf.badge = 1
    #   @notf.alert = @apn_comment.custom_message(device_id.member_id)
    #   @notf.sound = true
    #   @notf.custom_properties = @custom_properties
    #   @notf.save!
    # end

    find_recipient_notify.each do |member|
      member.apn_devices.each do |device|
        @notf = Apn::Notification.new
        @notf.device_id = device.id
        @notf.badge = 1
        @notf.alert = @apn_comment.custom_message(member.id)
        @notf.sound = true
        @notf.custom_properties = @custom_properties
        @notf.save!
      end
    end

    find_recipient_notify.each do |member|
      NotifyLog.create!(sender_id: member_id, recipient_id: member.id, message: @apn_comment.custom_message(member.id), custom_properties: @custom_properties.merge!(hash_custom))
    end

    Apn::App.first.send_notifications
  end

end
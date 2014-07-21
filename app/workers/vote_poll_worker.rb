class VotePollWorker
  include Sidekiq::Worker
  include SymbolHash

  def perform(member, poll, custom_data = {})
    anonymous = custom_data[:anonymous]

    member_id = member.id
    
    @apn_poll = Apn::VotePoll.new(member, poll)

    recipient_ids = @apn_poll.recipient_ids

    find_recipient ||= Member.where(id: recipient_ids)

    # device_ids = find_recipient.collect {|u| u.apn_devices.collect(&:id)}.flatten

    find_recipient_notify ||= Member.where(id: recipient_ids - [member_id])

    @custom_properties = { 
      poll_id: poll.id
    }


    # device_ids.each do |device_id|
    #   @notf = Apn::Notification.new
    #   @notf.device_id = device_id
    #   @notf.badge = 1
    #   @notf.alert = @apn_poll.custom_message
    #   @notf.sound = true
    #   @notf.custom_properties = @custom_properties
    #   @notf.save!
    # end

    # find_recipient.each do |member|
    #   NotifyLog.create(sender_id: member_id, recipient_id: member.id, message: @apn_poll.custom_message, custom_properties: @custom_properties.merge!(hash_custom))
    # end

    find_recipient_notify.each do |member|
      member.apn_devices.each do |device|
        @notf = Apn::Notification.new
        @notf.device_id = device.id
        @notf.badge = 1
        @notf.alert = @apn_poll.custom_message
        @notf.sound = true
        @notf.custom_properties = @custom_properties
        @notf.save!
      end
    end

    find_recipient_notify.each do |member|
      hash_custom = {
        anonymous: anonymous,
        type: TYPE[:poll],
        action: ACTION[:vote],
        poll: PollSerializer.new(poll).as_json()
      }

      group = check_in_group(member)

      if group.present? 
        hash_custom.merge!( { group: group.as_json() })
      end

      NotifyLog.create!(sender_id: member_id, recipient_id: member.id, message: @apn_poll.custom_message, custom_properties: @custom_properties.merge!(hash_custom))
    end

    Apn::App.first.send_notifications
  end

  def check_in_group(member)
    group_of_receiver = member.cached_get_group_active
    poll_in_group = Group.joins(:poll_groups).where("poll_id = #{poll.id}").uniq
  end

end
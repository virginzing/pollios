class VotePollWorker
  include Sidekiq::Worker
  include SymbolHash

  def perform(member_id, poll_id, custom_data = {})
    member = Member.find(member_id)
    poll = Poll.cached_find(poll_id)
    
    anonymous = custom_data[:anonymous]

    member_id = member.id
    
    @apn_poll = Apn::VotePoll.new(member, poll)

    recipient_ids = @apn_poll.recipient_ids

    find_recipient ||= Member.where(id: recipient_ids)

    # device_ids = find_recipient.collect {|u| u.apn_devices.collect(&:id)}.flatten

    find_recipient_notify ||= Member.where(id: recipient_ids - [member_id])

    poll_within_group ||= Group.joins(:poll_groups).where("poll_id = #{poll.id}").uniq

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

      check_group = check_in_group(member, poll_within_group)
      # puts "group detail => #{check_group}, group present => #{check_group.present?}"
      if check_group.present? 
        # puts "merge group detail"
        new_hash = hash_custom.merge!( Hash["group" => check_group.as_json()] )
      else
        new_hash = hash_custom
      end

      # puts "hash_custom => #{new_hash}"

      NotifyLog.create!(sender_id: member_id, recipient_id: member.id, message: @apn_poll.custom_message, custom_properties: @custom_properties.merge!(new_hash))
    end

    Apn::App.first.send_notifications
  end

  def check_in_group(member, poll_with_group)
    group_of_receiver = member.cached_get_group_active
    group = (poll_with_group && group_of_receiver).first
    # puts "member => #{member.id}, group => #{group.as_json}"
    group
  end

end
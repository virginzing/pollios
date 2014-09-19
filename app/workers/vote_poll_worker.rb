class VotePollWorker
  include Sidekiq::Worker
  include SymbolHash

  def perform(member_id, poll_id, anonymous_status)
    begin
      member = Member.find(member_id)
      poll = Poll.find_by(id: poll_id)
      anonymous = anonymous_status
      member_id = member.id
      
      @apn_poll = Apn::VotePoll.new(member, poll)

      recipient_ids = @apn_poll.recipient_ids

      find_recipient ||= Member.where(id: recipient_ids)

      find_recipient_notify ||= Member.where(id: recipient_ids - [member_id])

      if poll.in_group_ids != "0"
        @poll_within_group ||= Group.joins(:poll_groups).where("poll_groups.poll_id = #{poll_id} AND poll_groups.share_poll_of_id = 0").uniq
      end

      @custom_properties = { 
        poll_id: poll.id
      }

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

      if @poll_within_group.present?
        group_options = Hash["group" => @poll_within_group.first.as_json()]
        @hash_custom = @custom_properties.merge!(group_options)
      else
        @hash_custom = @custom_properties
      end

      find_recipient_notify.each do |member|
        hash_custom = {
          anonymous: anonymous,
          type: TYPE[:poll],
          action: ACTION[:vote],
          poll: PollSerializer.new(poll).as_json()
        }
        
        # check_group = check_in_group(member, poll_within_group)
        # # puts "group detail => #{check_group}, group present => #{check_group.present?}"
        # if check_group.present? 
        #   # puts "merge group detail"
        #   new_hash = hash_custom.merge!( Hash["group" => check_group.as_json()] )
        # else
        #   new_hash = hash_custom
        # end

        NotifyLog.create!(sender_id: member_id, recipient_id: member.id, message: @apn_poll.custom_message, custom_properties: @hash_custom)
      end

      Apn::App.first.send_notifications
    rescue => e
      puts "VotePollWorker => #{e.message}"
    end
  end

  # def check_in_group(member, poll_within_group)
  #   group_of_receiver = member.cached_get_group_active
  #   group = (poll_with_group && group_of_receiver).first
  #   group
  # end

end
class PollWorker
  include Sidekiq::Worker
  include SymbolHash
  
  sidekiq_options unique: true, :retry => 1

  def perform(member_id, poll_id, custom_data = {})
    begin
      @list_apn_notification = []
      @member = Member.find(member_id)
      @poll = Poll.find(poll_id)
      @poll_serializer_json ||= PollSerializer.new(@poll).as_json()

      member_id = @member.id

      @apn_poll = ApnPoll.new(@member, @poll)

      recipient_ids = @apn_poll.recipient_ids

      find_recipient ||= Member.where(id: recipient_ids).uniq

      @count_notification = CountNotification.new(find_recipient)

      device_ids ||= @count_notification.device_ids

      member_ids ||= @count_notification.member_ids

      hash_list_member_badge ||= @count_notification.hash_list_member_badge

      @custom_properties = {
        type: TYPE[:poll],
        poll_id: @poll.id,
        series: @poll.series
      }

      device_ids.each_with_index do |device_id, index|
        apn_custom_properties = {
          type: TYPE[:poll],
          poll_id: @poll.id,
          series: @poll.series,
          notify: hash_list_member_badge[member_ids[index]]
        }

        @notf = Apn::Notification.new
        @notf.device_id = device_id
        @notf.badge = hash_list_member_badge[member_ids[index]]
        @notf.alert = @apn_poll.custom_message
        @notf.sound = true
        @notf.custom_properties = apn_custom_properties
        @notf.save!

        @list_apn_notification << @notf
      end

      find_recipient.each do |member|
        hash_custom = {
          action: ACTION[:create],
          poll: @poll_serializer_json,
          notify: hash_list_member_badge[member.id],
          worker: WORKER[:poll]
        }

        NotifyLog.create!(sender_id: member_id, recipient_id: member.id, message: @apn_poll.custom_message, custom_properties: @custom_properties.merge!(hash_custom))
      end

      Apn::App.first.send_notifications
    rescue => e
      puts "PollWorker => #{e.message}"
      @list_apn_notification.collect{|apn_notification| apn_notification.destroy }
    end
  end

end

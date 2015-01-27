class ReportPollWorker

  include Sidekiq::Worker
  include SymbolHash

  sidekiq_options unique: true

  def perform(member_id, poll_id)
    begin
      @member ||= Member.find_by(id: member_id)
      @poll ||= Poll.find_by(id: poll_id)
      @poll_serializer_json ||= PollSerializer.new(@poll).as_json()

      @report_notification = Apn::ReportPoll.new(@member, @poll)

      recipient_ids = @report_notification.recipient_ids

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
        @notf.alert = @report_notification.custom_message
        @notf.sound = true
        @notf.custom_properties = apn_custom_properties
        @notf.save!
      end

      find_recipient.each do |member_receive|
        hash_custom = {
          action: ACTION[:report],
          poll: @poll_serializer_json,
          notify: hash_list_member_badge[member_receive.id]
        }

        NotifyLog.create!(sender_id: @member.id, recipient_id: member_receive.id, message: @report_notification.custom_message, custom_properties: @custom_properties.merge!(hash_custom))
      end

      Apn::App.first.send_notifications

    rescue => e
      puts "ReportPollWorker => #{e.message}"
    end
  end

end
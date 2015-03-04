class SumCommentPollWorker
  include Sidekiq::Worker
  include SymbolHash

  sidekiq_options unique: true, :retry => 1

  def perform(poll_id)
    begin
      @list_apn_notification = []

      poll = Poll.raw_cached_find(poll_id)

      raise ArgumentError.new("Poll not found") if poll.nil?
      
      @poll_serializer_json ||= PollSerializer.new(poll).as_json()

      @apn_sum_comment = Apn::SumCommentPoll.new(poll)

      recipient_ids = @apn_sum_comment.recipient_ids

      find_recipient ||= Member.where(id: recipient_ids).uniq

      find_recipient_notify ||= Member.where(id: recipient_ids).uniq

      @count_notification = CountNotification.new(find_recipient_notify)

      get_hash_list_member_badge ||= @count_notification.get_hash_list_member_badge_count

      @custom_properties = {
        type: TYPE[:poll],
        poll_id: poll.id,
        series: poll.series
      }

      find_recipient_notify.each_with_index do |member, index|
        member.apn_devices.each do |device|
          apn_custom_properties = {
            type: TYPE[:poll],
            poll_id: poll.id,
            series: poll.series,
            notify: (get_hash_list_member_badge[member.id] + 1)
          }

          @notf = Apn::Notification.new
          @notf.device_id = device.id
          @notf.badge = (get_hash_list_member_badge[member.id] + 1)
          @notf.alert = @apn_sum_comment.custom_message
          @notf.sound = true
          @notf.custom_properties = apn_custom_properties
          @notf.save!

          @list_apn_notification << @notf
        end
        member.update_columns(notification_count: (get_hash_list_member_badge[member.id] + 1))
      end

      Apn::App.first.send_notifications
      poll.update(comment_notify_state: 0)
    rescue => e
      puts "SumCommentPollWorker => #{e.message}"
      poll = Poll.find_by(id: poll_id)
      poll.update(:comment_notify_state, 0) if poll.present?
      @list_apn_notification.collect{|apn_notification| apn_notification.destroy }

    end
  end
  
  
end
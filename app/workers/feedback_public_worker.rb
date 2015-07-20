class FeedbackPublicWorker
  include Sidekiq::Worker
  include SymbolHash

  sidekiq_options unique: true

  def perform(member_id, poll_series_id)
    @sender = Member.cached_find(member_id)
    @poll_series = PollSeries.cached_find(poll_series_id)
    @poll_series_serializer_json ||= QuestionnaireSerializer.new(@poll_series).as_json

    @poll_id_for_questionnaire = @poll_series.polls.select{|poll| poll if poll.order_poll }.min.id

    @apn_feedback ||= Apn::FeedbackPublic.new(@sender, @poll_series)

    recipient_ids = @apn_feedback.recipient_ids

    find_recipient ||= Member.where(id: recipient_ids).uniq

    @count_notification = CountNotification.new(find_recipient)

    device_ids ||= @count_notification.device_ids

    member_ids ||= @count_notification.member_ids

    hash_list_member_badge ||= @count_notification.hash_list_member_badge

    @custom_properties = {
      type: TYPE[:poll],
      poll_id: @poll_series.id,
      series: true
    }

    device_ids.each_with_index do |device_id, index|
      apn_custom_properties = {
        type: TYPE[:poll],
        poll_id: @poll_series.id,
        series: true,
        notify: hash_list_member_badge[member_ids[index]]
      }

      @notf = Apn::Notification.new
      @notf.device_id = device_id
      @notf.badge = hash_list_member_badge[member_ids[index]]
      @notf.alert = @apn_feedback.custom_message
      @notf.sound = true
      @notf.custom_properties = apn_custom_properties
      @notf.save!
    end

    find_recipient.each do |member|
      hash_custom = {
        action: ACTION[:create],
        poll: @poll_series_serializer_json,
        notify: hash_list_member_badge[member.id],
        poll_series_id: @poll_series.id,
        worker: WORKER[:questionnaire]
      }

      NotifyLog.create!(sender_id: @sender.id, recipient_id: member.id, message: @apn_feedback.custom_message, custom_properties: @custom_properties.merge!(hash_custom))
    end

    Apn::App.first.send_notifications
  end


end

class ApnQuestionnaireWorker
  include Sidekiq::Worker
  include SymbolHash

  sidekiq_options unique: true

  def perform(member_id, poll_series_id, group_id, custom_data = {})
    begin
      @member = Member.cached_find(member_id)
      @poll_series = PollSeries.cached_find(poll_series_id)
      @poll_series_serializer_json ||= QuestionnaireSerializer.new(@poll_series).as_json()

      @group = Group.find_by(id: group_id)
      member_id = @member.id

      @poll_id_for_questionnaire = @poll_series.polls.select{|poll| poll if poll.order_poll }.min.id

      @apn_questionnaire = AskQuestionnaire.new(@member, @poll_series, @group)

      recipient_ids = @apn_questionnaire.recipient_ids

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
        @notf.alert = @apn_questionnaire.custom_message
        @notf.sound = true
        @notf.custom_properties = apn_custom_properties
        @notf.save!
      end

      find_recipient.each do |member|
        hash_custom = {
          action: ACTION[:create],
          poll: @poll_series_serializer_json,
          notify: hash_list_member_badge[member.id]
        }

        NotifyLog.create!(sender_id: member_id, recipient_id: member.id, message: @apn_questionnaire.custom_message, custom_properties: @custom_properties.merge!(hash_custom))
      end

      Apn::App.first.send_notifications
    rescue => e
      puts "ApnPollWorker => #{e.message}"
    end
  end

end

class ApnQuestionnaireWorker
  include Sidekiq::Worker
  include SymbolHash

  def perform(member_id, poll_series_id, group_id, custom_data = {})
    begin
      @member = Member.find(member_id)
      @poll_series = PollSeries.find(poll_series_id)
      @group = Group.find(group_id)

      member_id = @member.id
      
      @apn_questionnaire = AskQuestionnaire.new(@member, @poll_series, @group)

      recipient_ids = @apn_questionnaire.recipient_ids

      find_recipient ||= Member.where(id: recipient_ids)

      device_ids = find_recipient.collect {|u| u.apn_devices.collect(&:id)}.flatten

      @custom_properties = { 
        poll_series_id: @poll_series.id
      }

      hash_custom = {
        type: TYPE[:poll_series],
        action: ACTION[:create],
        poll_series: QuestionnaireSerializer.new(@poll_series).as_json()
      }

      device_ids.each do |device_id|
        @notf = Apn::Notification.new
        @notf.device_id = device_id
        @notf.badge = 1
        @notf.alert = @apn_questionnaire.custom_message
        @notf.sound = true
        @notf.custom_properties = @custom_properties
        @notf.save!
      end

      find_recipient.each do |member|
        NotifyLog.create(sender_id: member_id, recipient_id: member.id, message: @apn_questionnaire.custom_message, custom_properties: @custom_properties.merge!(hash_custom))
      end

      Apn::App.first.send_notifications
    rescue => e
      puts "ApnPollWorker => #{e.message}"
    end
  end

end




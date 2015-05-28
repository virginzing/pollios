class ReceiveRandomRewardPollWorker
  include Sidekiq::Worker
  include SymbolHash

  sidekiq_options unique: true

  def perform(sender_id, poll_id, list_member)
    @list_apn_notification = []
    sender = Member.cached_find(sender_id)
    poll = Poll.cached_find(poll_id)

    @apn_receive_random_reward_poll = ApnReceiveRandomRewardPoll.new(sender, poll, list_member)

    recipient_ids = @apn_receive_random_reward_poll.recipient_ids

    find_recipient ||= Member.where(id: recipient_ids).uniq

    @count_notification = CountNotification.new(find_recipient)

    device_ids ||= @count_notification.device_ids

    member_ids ||= @count_notification.member_ids

    hash_list_member_badge ||= @count_notification.hash_list_member_badge

    list_hash_reward_with_member_ids ||= @apn_receive_random_reward_poll.list_hash_reward_with_member_ids

    @custom_properties = {
      type: TYPE[:reward]
    }

    device_ids.each_with_index do |device_id, index|
      apn_custom_properties = {
        type: TYPE[:reward],
        reward_id: list_hash_reward_with_member_ids[member_ids[index]],
        notify: hash_list_member_badge[member_ids[index]]
      }

      @notf = Apn::Notification.new
      @notf.device_id = device_id
      @notf.badge = hash_list_member_badge[member_ids[index]]
      @notf.alert = @apn_receive_random_reward_poll.custom_message
      @notf.sound = true
      @notf.custom_properties = apn_custom_properties
      @notf.save!

      @list_apn_notification << @notf
    end

    find_recipient.each do |member|
      hash_custom = {
        reward_id: list_hash_reward_with_member_ids[member.id],
        notify: hash_list_member_badge[member.id],
        worker: WORKER[:receive_random_reward_poll]
      }

      NotifyLog.create!(sender_id: sender.id, recipient_id: member.id, message: @apn_receive_random_reward_poll.custom_message, custom_properties: @custom_properties.merge!(hash_custom))
    end

    Apn::App.first.send_notifications

  rescue => e
    puts "ReceiveRandomRewardPollWorker => #{e.message}"
  end
end
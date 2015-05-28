class RewardWorker
  include Sidekiq::Worker
  include SymbolHash

  sidekiq_options unique: true
  
  def perform(reward_id)
    @reward = CampaignMember.cached_find(reward_id)
    @member = @reward.campaign.member

    @apn_reward = Apn::Reward.new(@reward)

    recipient_ids = @apn_reward.recipient_ids

    find_recipient_notify ||= Member.where(id: recipient_ids).uniq

    @count_notification = CountNotification.new(find_recipient_notify)

    hash_list_member_badge ||= @count_notification.hash_list_member_badge

    @custom_properties = {
      type: TYPE[:reward]
    }

    find_recipient_notify.each_with_index do |member, index|
      member.apn_devices.each do |device|
        apn_custom_properties = {
          type: TYPE[:reward],
          reward_id: @reward.id,
          notify: hash_list_member_badge[member.id] || 0
        }

        @notf = Apn::Notification.new
        @notf.device_id = device.id
        @notf.badge = hash_list_member_badge[member.id]
        @notf.alert = @apn_reward.custom_message
        @notf.sound = true
        @notf.custom_properties = apn_custom_properties
        @notf.save!
      end
    end

    find_recipient_notify.each do |member|
      hash_custom = {
        notify: hash_list_member_badge[member.id] || 0,
        reward_id: @reward.id,
        worker: WORKER[:reward]
      }

      NotifyLog.create!(sender_id: @member.id, recipient_id: member.id, message: @apn_reward.custom_message, custom_properties: @custom_properties.merge!(hash_custom))
    end

    Apn::App.first.send_notifications
  rescue => e
    puts "RewardWorker => #{e.message}"
  end
end
namespace :notify do
  desc 'Destroy NotifyLog records, keep only 100 latest records'
  task clean: :environment do
    Member.all.each do |member|
      NotifyLog.where(recipient_id: member.id).order(created_at: :desc).offset(100).destroy_all
    end
  end

  desc 'Change Reward NotifyLog custom_properties for support legacy api and v1 api'
  task reward_update: :environment do
    NotifyLog.without_deleted.where('custom_properties LIKE ?', '%type: Reward%').each do |notify_log|
      old_custom_properties = notify_log.custom_properties
      new_custom_properties = {
        type: old_custom_properties[:type],
        reward_id: old_custom_properties[:reward_id],
        redeemable_info: { 
          redeem_id: old_custom_properties[:reward_id] || old_custom_properties[:redeemable_info][:redeem_id]
        },
        notify: old_custom_properties[:notify],
        worker: old_custom_properties[:worker]
      }
      notify_log.update!(custom_properties: new_custom_properties)
    end
  end
end

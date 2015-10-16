namespace :notify do
	desc "Destroy NotifyLog but keep recent 100 records"
	task clean: :environment do
		Member.all.each do |member|
			NotifyLog.where(recipient_id: member.id).order(created_at: :desc).offset(100).destroy_all
		end
	end
end

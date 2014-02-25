namespace :poll_member do
  desc "Analysis"
  task analysis: :environment do
    PollMember.all.each do |pm|
      if pm.poll.present?
        pm.update_attributes!(public: pm.poll.public, series: pm.poll.series, expire_date: pm.poll.expire_date)
      end
    end
  end

end

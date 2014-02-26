namespace :poll do
  desc "Choice Count"
  task choice_count: :environment do
    Poll.all.each do |poll|
      poll.update(choice_count: poll.choices.count)
    end
  end

  desc "Update History Vote"
  task :update_history_vote => :environment do
    HistoryVote.all.each do |hv|
      poll_series_id = 0
      if hv.poll.present?
        if hv.poll.series
          poll_series_id = hv.poll.poll_series_id
        end
        hv.update_attributes!(poll_series_id: poll_series_id)
      else
        hv.destroy
      end
    end
  end

end

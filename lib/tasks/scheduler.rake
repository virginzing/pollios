namespace :scheduler do
  desc "test recurring"
  task recurring: :environment do
    puts "poll recurring test run"
    poll = Poll.get_poll_hourly

    feedback = PollSeries.get_feedback_hourly
  end

  desc "Recurring Feedback"

  task recurring_feedback: :environment do
    PollSeries.get_feedback_hourly
  end

  desc "alert notification for save poll"
  
  # task alert_save_poll: :environment do
  #   puts "alert notification for save poll later"
  #   Member.alert_save_poll
  # end


end

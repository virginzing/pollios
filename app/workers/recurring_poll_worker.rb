class RecurringPollWorker
  include Sidekiq::Worker

  def perform
    puts "Poll recurring - every 1 hour"

    poll = Poll.get_poll_hourly

    feedback = PollSeries.get_feedback_hourly
  end


end
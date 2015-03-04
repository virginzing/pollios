class SavePollWorker
  include Sidekiq::Worker

  def perform
    puts "Alert Notification for Save poll later"
    Member.alert_save_poll
  end
  
end
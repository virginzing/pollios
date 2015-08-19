class AutoDeleteNotificationLogEvery3DaysWorker
  include Sidekiq::Worker
  include SymbolHash

  def perform
    Apn::Notification.where("sent_at < ?", 3.days.ago).delete_all
  end
end

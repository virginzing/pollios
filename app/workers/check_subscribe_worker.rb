class CheckSubscribeWorker
  include Sidekiq::Worker

  def perform
    Member.check_subscribe
    Member.notify_nearly_expire_subscription
  end
  
end
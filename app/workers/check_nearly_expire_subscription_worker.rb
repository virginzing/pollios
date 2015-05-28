class CheckNearlyExpireSubscriptionWorker
  include Sidekiq::Worker
  include SymbolHash

  def perform
    Member.notify_nearly_expire_subscription
  end

end
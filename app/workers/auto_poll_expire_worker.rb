class AutoPollExpireWorker
  include Sidekiq::Worker
  include SymbolHash

  sidekiq_options unique: true

  def perform
    Poll.close_all_poll_that_expired  
  end

end
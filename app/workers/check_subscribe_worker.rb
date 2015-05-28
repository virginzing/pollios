class CheckSubscribeWorker
  include Sidekiq::Worker
  include SymbolHash

  def perform
    Member.check_subscribe
  end
  
end
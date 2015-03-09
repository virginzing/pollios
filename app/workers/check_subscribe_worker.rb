class CheckSubscribeWorker
  include Sidekiq::Worker

  def perform
    Member.check_subscribe
  end
  
end
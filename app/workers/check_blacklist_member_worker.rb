class CheckBlacklistMemberWorker
  include Sidekiq::Worker

  def perform
    Member.check_blacklist_members
  end
end
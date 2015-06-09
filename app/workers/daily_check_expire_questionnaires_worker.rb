class DailyCheckExpireQuestionnairesWorker
  include Sidekiq::Worker
  include SymbolHash

  sidekiq_options unique: true

  def perform
    PollSeries.daily_check_expire  
  end
  
end
class ResetPopularTagWorker
  include Sidekiq::Worker

  def perform
    Rails.cache.delete('tags_popular')
  end
  
end
class FlushCachePollWatchWorker
  include Sidekiq::Worker
  
  def perform(list_member_ids)
    list_member_ids.each do |member_id|
      Rails.cache.delete([member_id, 'watcheds'])
    end
  end

end
class FlushCachePollVoteWorker
  include Sidekiq::Worker
  
  def perform(list_member_ids)
    list_member_ids.each do |member_id|
      Rails.cache.delete([member_id, 'my_voted'])
    end
  end

end

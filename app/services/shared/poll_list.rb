class Shared::PollList
  class << self
    def popular_public_polls
      Poll.public_available.order("vote_all desc").limit(3)
    end
  end
end
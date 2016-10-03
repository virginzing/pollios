module V1::Groups::Polls
  class DetailDecorator < V1::ApplicationDecorator
    attr_reader :index

    delegate :title, :member, :get_photo, :vote_all, :close_status

    def initialize(poll, index)
      @index ||= index

      super(poll)
    end

    def poll
      object
    end

    def next_poll_url
      return '' if last_poll?

      "/groups/#{poll.groups.first.public_id}/polls/#{next_index}"
    end

    def prev_poll_url
      return '' if first_poll?

      "/groups/#{poll.groups.first.public_id}/polls/#{last_index}"
    end

    def close_poll_url
      "/groups/#{poll.groups.first.public_id}/polls/#{@index}/close"
    end

    def vote_result_url
      "/groups/#{poll.groups.first.public_id}/polls/#{@index}/result"
    end

    def next_poll_button_class
      return 'disabled' if last_poll?
    end

    def prev_poll_button_class
      return 'disabled' if first_poll?
    end

    def first_poll?
      poll.id == poll.groups.first.polls.last.id
    end

    def last_poll?
      poll.id == poll.groups.first.polls.first.id
    end

    def next_index
      @index.to_i + 1
    end

    def last_index
      @index.to_i - 1
    end
  end
end

module V1::Groups::Polls
  class ResultDecorator < DetailDecorator
    delegate :choices

    def choices
      {
        label: poll.choices.map(&:answer),
        data: poll.choices.map(&:vote)
      }
    end

    def next_poll_url
      return '' if last_poll?

      "#{base_url}/#{next_index}/result"
    end

    def prev_poll_url
      return '' if first_poll?

      "#{base_url}/#{last_index}/result"
    end
  end
end

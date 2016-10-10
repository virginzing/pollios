module V1::Polls
  class DetailDecorator < V1::ApplicationDecorator
    delegate :title, :member, :get_photo

    def poll
      object
    end

    def choices
      # rubocop:disable Style/SingleLineBlockParams
      # rubocop:disable Lint/UselessAssignment
      total_vote = poll.choices.inject(0) { |sum, choice| sum += choice.vote }

      poll.choices.map { |choice| Choices::DetailDecorator.new(choice, total_vote) }
    end
  end
end

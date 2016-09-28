module V1::Polls
  class QsnccPollDecorator < V1::ApplicationDecorator
    delegate :title, :member, :get_photo, :choices

    def poll
      object
    end

    def choices
      {
        label: poll.choices.map { |choice| choice.answer },
        data: poll.choices.map { |choice| choice.vote }
      }
    end
  end
end

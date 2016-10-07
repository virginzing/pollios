module V1::Polls
  class DetailDecorator < V1::ApplicationDecorator
    attr_reader :index, :hostname

    delegate :title, :member, :get_photo

    def initialize(poll)
      @index ||= index
      @hostname ||= hostname

      super(poll)
    end

    def poll
      object
    end

    def choices
      poll.choices.map { |choice| Choices::DetailDecorator.decorate(choice) }
    end
  end
end

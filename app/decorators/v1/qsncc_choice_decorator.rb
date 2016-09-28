module V1
  class QsnccChoiceDecorator < V1::ApplicationDecorator

    delegate :answer, :vote

    def choice
      object
    end

    def vote_count
      choice.vote
    end
  end
end

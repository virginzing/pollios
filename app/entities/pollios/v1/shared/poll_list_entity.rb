module Pollios::V1::Shared
  class PollListEntity < Pollios::V1::BaseEntity

    expose :next_index
    expose :polls, with: PollForListEntity

    def polls
      object.polls_by_page(object.send(type))
    end

    def type
      options[:poll]
    end

    def next_index
      object.next_index(polls)
    end

  end
end
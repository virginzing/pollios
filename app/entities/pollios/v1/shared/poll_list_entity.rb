module Pollios::V1::Shared
  class PollListEntity < Pollios::V1::BaseEntity

    expose :next_index
    expose :polls, with: PollDetailEntity

    def polls
      object.send(type)
    end

    def type
      options[:poll]
    end

    def next_index
      object.next_index(polls)
    end

  end
end
module V1::Polls
  class PostController < GetController
    def vote
      @current_member_poll_action.vote(vote_params)

      redirect_to :back
    end
  end
end

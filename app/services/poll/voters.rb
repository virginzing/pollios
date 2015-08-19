class Poll::Voters
    def initialize(params)
        @params = params
    end

    def members
        if @params[:choice_id]
            Member.joins(:history_votes).where("history_votes.choice_id IN (?)", @params[:choice_id])
        else
            []
        end
    end
end
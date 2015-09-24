class Poll::Voters
    def initialize(params)
        @params = params
    end

    def members
        result = []
        if @params[:choice_id]
            result = Member.joins(:history_votes).where("history_votes.choice_id IN (?)", @params[:choice_id])
        end
        return result
    end
end
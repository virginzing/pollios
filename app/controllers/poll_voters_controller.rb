class PollVotersController < ApplicationController

    layout 'admin'
    before_action :authenticate_admin!

    def index
        voters = Poll::Voters.new(params)
        @all_voters = voters.members
    end
end

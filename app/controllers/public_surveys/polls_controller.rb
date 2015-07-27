class PublicSurveys::PollsController < ApplicationController

  before_action :only_public_survey

  def index
    @init_poll_public = Company::PollPublic.new(current_company)
    @public_polls = @init_poll_public.get_list_public_poll.decorate
  end

  def new
    @poll = Poll.new
  end

  def show

  end

end

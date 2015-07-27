class PublicSurveys::FeedbacksController < ApplicationController

  before_action :only_public_survey

  def index

  end
end

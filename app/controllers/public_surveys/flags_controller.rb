class PublicSurveys::FlagsController < ApplicationController

  before_action :only_public_survey

  def index

  end


end

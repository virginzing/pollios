class SearchesController < ApplicationController
  before_action :set_current_member
  before_action :compress_gzip


  def users_and_groups
    @groups = []
    @members = []
  end

end

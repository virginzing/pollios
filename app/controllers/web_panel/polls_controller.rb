module WebPanel
  class PollsController < ApplicationController
    before_action :signed_user
    before_action :set_company, only: [:create_new_poll, :create_new_public_poll]
    before_action :only_public_survey, only: [:create_new_public_poll]

    def create_new_public_poll
      @poll = Poll.new
    end

    def create_new_poll
      @poll = Poll.new
      @group_list = Company::ListGroup.new(current_company).show_in_groups
    end

    def poll_latest
      @poll_latest_data = []
      @choice_poll_latest = []

      @init_poll ||= PollOfGroup.new(current_member, current_member.get_company.groups, {}, true)
      @poll_latest = @init_poll.get_poll_of_group_company.decorate.first

      if @poll_latest.present?
        @choice_poll_latest = @poll_latest.cached_choices.collect{|e| [e.answer, e.vote] }
        @choice_poll_latest_max = @choice_poll_latest.collect{|e| e.last }.max

        @choice_poll_latest.each do |choice|
          @poll_latest_data << { "name" => choice.first, "value" => choice.last }
        end
      end

      render layout: false
    end

    def poll_latest_in_public
      @poll_latest_in_public_data = []
      @choice_poll_latest_in_public = []

      @init_poll ||= Company::PollPublic.new(set_company)
      @poll_latest_in_public = @init_poll.get_list_public_poll.decorate.first

      if @poll_latest_in_public.present?
        @choice_poll_latest_in_public = @poll_latest_in_public.cached_choices.collect{|e| [e.answer, e.vote] }
        @choice_poll_latest_in_public_max = @choice_poll_latest_in_public.collect{|e| e.last }.max

        @choice_poll_latest_in_public.each do |choice|
          @poll_latest_in_public_data << { "name" => choice.first, "value" => choice.last }
        end
      end

      render layout: false
    end

    def poll_popular
      @init_poll ||= PollOfGroup.new(current_member, current_member.get_company.groups, {}, true)
      @poll_popular = @init_poll.get_poll_of_group_company.where("vote_all != 0").order("vote_all desc").limit(5).decorate.sample(5).first
      @choice_poll_popular = []
      render layout: false
    end

    private

    def set_company
      @company = current_member.company || current_member.company_member.company
    end

  end
end

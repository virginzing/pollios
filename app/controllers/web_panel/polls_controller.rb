module WebPanel
  class PollsController < ApplicationController

    before_action :signed_user, except: [:load_poll, :poke_poll, :poke_dont_vote, :poke_dont_view, :poke_view_no_vote]
    before_action :set_company, only: [:create_new_poll, :create_new_public_poll]
    before_action :only_public_survey, only: [:create_new_public_poll]

    def load_poll
      if params[:trigger].to_b
        @poll = Poll.where("title LIKE ? AND series = 'f' AND id NOT IN (?)", "%#{params[:q]}%", Trigger.all.map(&:triggerable_id))
      else
        @poll = Poll.where("title LIKE ? AND series = 'f'", "%#{params[:q]}%")
      end

      @poll_as_json = ActiveModel::ArraySerializer.new(@poll, each_serializer: LoadPollSerializer).to_json()

      render json: @poll_as_json, root: false
    end

    def create_poll
      Poll.transaction do
        in_group = false
        @build_poll = BuildPoll.new(current_member, polls_params, {choices: params[:choices]})
        new_poll_binary_params = @build_poll.poll_binary_params
        @poll = Poll.new(new_poll_binary_params)
        @poll.choice_count = @build_poll.list_of_choice.size
        @poll.qrcode_key = @poll.generate_qrcode_key

        if @poll.save
          @choice = Choice.create_choices_on_web(@poll.id, @build_poll.list_of_choice)

          PollCompany.create_poll(@poll, set_company, :web)

          @poll.create_tag(@build_poll.title_with_tag)

          @poll.create_watched(current_member, @poll.id)

          if @poll.in_group_ids != "0"
            in_group = true
            Group.add_poll(current_member, @poll, @poll.in_group_ids.split(",").collect{ |e| e.to_i } )
            Company::TrackActivityFeedPoll.new(current_member, @poll.in_group_ids, @poll, "create").tracking if @poll.in_group
          end

          unless @poll.qr_only
            current_member.poll_members.create!(poll_id: @poll.id, share_poll_of_id: 0, public: @poll.public, series: @poll.series, expire_date: @poll.expire_date, in_group: in_group)
          end

          PollStats.create_poll_stats(@poll)
          current_member.flush_cache_about_poll
          Activity.create_activity_poll(current_member, @poll, 'Create')
          @poll.flush_cache
          flash[:success] = "Create poll successfully."
          redirect_to current_member.get_company.present? ? company_polls_path : polls_path
        else
          redirect_to company_polls_path
        end
      end
    end

    def create_new_public_poll
      @poll = Poll.new
    end

    def create_new_poll
      @poll = Poll.new
      @group_list = Company::ListGroup.new(set_company).show_in_groups
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

    def poke_poll
      respond_to do |format|
        if params[:sender_id] && params[:member_id] && params[:id]
          PokePollWorker.perform_async(params[:sender_id], [params[:member_id]], params[:id])
          format.json { render json: [], status: 200 }
        else
          format.json { render json: { error_message: "No" }, status: :unprocessable_entity }
        end
      end
    end

    def poke_dont_vote
      respond_to do |format|
        init_company = PollDetailCompany.new(find_member.get_company.groups, find_poll)
        @member_novoted_poll = init_company.get_member_not_voted_poll

        if @member_novoted_poll.length > 0
          PokePollWorker.perform_async(find_member.id, @member_novoted_poll.collect{|e| e.id }, params[:id])

          format.json { render json: [], status: 200 }
        else
          format.json { render json: { error_message: "No" }, status: :unprocessable_entity }
        end
      end
    end

    def poke_dont_view
      respond_to do |format|
        init_company = PollDetailCompany.new(find_member.get_company.groups, find_poll)
        @member_noviewed_poll = init_company.get_member_not_viewed_poll

        if @member_noviewed_poll.length > 0
          PokePollWorker.perform_async(find_member.id, @member_noviewed_poll.collect{|e| e.id }, params[:id])

          format.json { render json: [], status: 200 }
        else
          format.json { render json: { error_message: "No" }, status: :unprocessable_entity }
        end
      end
    end

    def poke_view_no_vote
      respond_to do |format|
        init_company = PollDetailCompany.new(find_member.get_company.groups, find_poll)
        @member_viewed_no_vote_poll = init_company.get_member_viewed_not_vote_poll

        if @member_viewed_no_vote_poll.length > 0
          PokePollWorker.perform_async(find_member.id, @member_viewed_no_vote_poll.collect{|e| e.id }, params[:id])

          format.json { render json: [], status: 200 }
        else
          format.json { render json: { error_message: "Don't have a data" }, status: :unprocessable_entity }
        end
      end
    end

    private

    def polls_params
      params.require(:poll).permit(:draft, :show_result, :creator_must_vote, :qr_only, :require_info, :allow_comment, :member_type, :campaign_id, :member_id, :title, :public, :expire_within, :expire_date, :choice_count, :tag_tokens, :recurring_id, :type_poll, :choice_one, :choice_two, :choice_three, :photo_poll, :title_with_tag, group_id: [], choices_attributes: [:id, :answer, :_destroy])
    end

    def set_company
      @company = current_member.company || current_member.company_member.company
    end

    def find_member
      Member.find(params[:member_id])
    end

    def find_poll
      Poll.find(params[:id])
    end

  end
end

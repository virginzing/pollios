RailsAdmin.config do |config|
  Rails.application.eager_load!
  ### Popular gems integration

  ## == Devise ==
  config.authenticate_with do
    warden.authenticate! scope: :admin
  end

  config.current_user_method(&:current_admin)

  config.included_models = ['Admin', 'Poll', 'PollSeries', 'Choice', 'Member', 'Provider', 'Friend', 'Campaign', 'Tag', 'Tagging', 'Guest', 'Group', 'Recurring', 'SharePoll', 'PollGroup', 'PollMember', 'HiddenPoll',
    'HistoryView', 'HistoryVote', 'Province', 'GroupMember', 'CampaignMember', 'Apn::Device', 'Apn::App', 'Apn::Notification', 'Template']


  config.main_app_name = Proc.new { |controller| [ "Pollios - #{controller.params[:action].try(:titleize)}" ] }


  ## == Cancan ==
  # config.authorize_with :cancan

  ## == PaperTrail ==
  config.audit_with :paper_trail, 'Admin', 'PaperTrail::Version' # PaperTrail >= 3.0.0

  ### More at https://github.com/sferik/rails_admin/wiki/Base-configuration

  config.actions do
    dashboard                     # mandatory
    index                         # mandatory
    new
    export
    bulk_delete
    show
    edit
    delete

    ## With an audit adapter, you can add:
    history_index
    history_show
  end
end

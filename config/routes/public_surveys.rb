scope module: 'public_surveys' do
  scope 'public-surveys' do
    get 'dashboard',  to: 'dashboards#index', as: :public_survey_dashboard

    resources :polls, as: 'public_survey_polls' do

    end

    scope 'feedbacks' do
      get '/',  to: 'feedbacks#index',  as: :public_survey_feedbacks
    end

    scope 'groups' do
      get '/',  to: 'groups#index', as: :public_survey_groups
    end

    scope 'campaigns' do
      get '/',  to: 'campaigns#index',  as: :public_survey_campaigns
    end

    scope 'flags' do
      get '/',  to: 'flags#index',  as: :public_survey_flags
      get 'polls',  to: 'flags#index',  as: :public_survey_flags_polls
    end

    scope 'settings' do
      get '/',  to: 'settings#index', as: :public_survey_settings
    end
  end
end

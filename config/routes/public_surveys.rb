scope module: 'public_surveys' do
  scope 'public-surveys' do
    get 'dashboard',  to: 'dashboards#index', as: :public_survey_dashboard

    resources :polls, as: 'public_survey_polls' do

    end

    resources :feedbacks, as: 'public_survey_feedbacks' do

    end

    resources :groups, as: 'public_survey_groups' do
      collection do
        get 'new_poll'
      end

      member do
        delete 'remove_member'
      end
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

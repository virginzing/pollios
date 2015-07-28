scope module: 'public_surveys' do
  scope 'public-surveys' do
    get 'dashboard',  to: 'dashboards#index', as: :public_survey_dashboard

    resources :polls, as: 'public_survey_polls' do
      member do
        get 'campaigns'
      end
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

    resources :campaigns, as: 'public_survey_campaigns' do

    end

    resources :flags, as: 'public_survey_flags' do

    end

    resources :settings, as: 'public_survey_settings' do

    end
  end
end

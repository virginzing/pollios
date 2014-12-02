if Rails.env.development?
  ApiTaster.routes do
    desc "Overall Timeline"
    get '/poll/:member_id/overall_timeline', {
      member_id: 179,
      api_version: 6
    }

    desc "Public Timeline"
    get '/poll/:member_id/public_timeline', {
      member_id: 179,
      api_version: 6
    }

    desc "API list polll of surveyor"

    get '/api/surveyor/polls', {
      member_id: 179
    }

    get '/api/surveyor/polls/:id/members_surveyable', { 
      member_id: 179,
      id: ""
    }

    get '/api/surveyor/questionnaires/:id/members_surveyable', {
      member_id: 179,
      id: ""
    }

  end
end
if Rails.env.development?
  member_id = 179
  api_version = 6

  ApiTaster.routes do
    desc "Overall Timeline"
    get '/poll/:member_id/overall_timeline', {
      member_id: member_id,
      api_version: api_version
    }

    desc "Public Timeline"
    get '/poll/:member_id/public_timeline', {
      member_id: member_id,
      api_version: api_version
    }

    desc "API list polll of surveyor"

    get '/api/surveyor/polls', {
      member_id: member_id
    }

    get '/api/surveyor/polls/:id/members_surveyable', { 
      member_id: member_id,
      id: ""
    }

    get '/api/surveyor/questionnaires/:id/members_surveyable', {
      member_id: member_id,
      id: ""
    }

    desc "Don't see poll"

    post '/poll/:id/un_see', {
      id: "",
      member_id: member_id
    }

    desc "Don't see questionnaire"

    post '/questionnaire/:id/un_see', {
      id: "",
      member_id: member_id
    }

    desc "Detail of poll"

    get '/poll/:id/detail', {
      id: "",
      member_id: member_id
    }

  end
end
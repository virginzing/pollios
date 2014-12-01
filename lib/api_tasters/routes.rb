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
  end
end
class ApiConstraints
  ACTIVE_API_VERSIONS = ['v1', 'v2'] 

  def initialize(options)
    @version = options[:version]
    @default = options[:default]
  end
    
  def matches?(req)
    if req.headers['Accept'] =~ /application\/vnd.pollios.v([1-2]+)/
      ver = $1.to_i
      ACTIVE_API_VERSIONS.include?("v#{ver}") ? @version == ver : @default
    else
      @default
    end
  end

end
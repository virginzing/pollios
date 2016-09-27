Rails.application.config.paths.add File.join('app', 'api'), glob: File.join('**', '*.rb')
Rails.application.config.autoload_paths += Dir[Rails.root.join('app', 'api', '*')]

class Length < Grape::Validations::Base
  def validate_param!(attr_name, params)
    return if params[attr_name].length <= @option

    fail Grape::Exceptions::Validation \
    , params: [@scope.full_name(attr_name)] \
    , message: "must be at the most #{@option} characters long"
  end
end

class EachLength < Grape::Validations::Base
  def validate_param!(attr_name, params)
    return if params[attr_name].map { |param| param.length <= @option }.reduce(:&)

    fail Grape::Exceptions::Validation \
    , params: [@scope.full_name(attr_name)] \
    , message: "must be at the most #{@option} characters long"
  end
end
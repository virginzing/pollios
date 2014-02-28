module PollSeriesHelper
  extend Enumerize
  extend ActiveModel::Naming

  enumerize :type_series, :in => { :normal => 0, :same_chocie => 1 }, scope: :having_type_series, predicates: true

end

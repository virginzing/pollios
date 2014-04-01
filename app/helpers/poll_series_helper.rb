module PollSeriesHelper
  extend Enumerize
  extend ActiveModel::Naming

  enumerize :type_series, :in => { :normal => 0, :same_chocie => 1 }, scope: :having_type_series, predicates: true
  enumerize :type_poll, :in => { binary: 1, rating: 2, freeform: 3 }, predicates: true, scope: :having_type, default: :freeform

end

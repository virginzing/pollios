module PollsHelper

  extend Enumerize
  extend ActiveModel::Naming

  # enumerize :series,  :in => { poll: false, questionnaire: true}, predicates: true, scope: :having_series
  enumerize :type_poll, :in => { binary: 1, rating: 2, freeform: 3 }, predicates: true, scope: :having_type, default: :freeform
  enumerize :status_poll, :in => { gray: 0, white: 1, black: -1 }, predicates: :true, scope: :having_status_poll, default: :gray


end

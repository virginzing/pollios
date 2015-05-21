module PollCompaniesHelper
  extend Enumerize
  extend ActiveModel::Naming

  enumerize :post_from, :in => { web: 1, mobile: 2 }, predicates: true, scope: true, default: :web

end
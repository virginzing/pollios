class Mention < ActiveRecord::Base
  belongs_to :comment
  belongs_to :mentioner, class_name: "Member"
  belongs_to :mentionable, class_name: "Member"
end

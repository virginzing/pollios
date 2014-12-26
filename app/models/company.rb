class Company < ActiveRecord::Base

  belongs_to :member

  has_many :company_members, dependent: :destroy
  has_many :members, through: :company_members, source: :member

  has_many :invite_codes, dependent: :destroy
  has_many :branches, dependent: :destroy
  
  has_many :group_companies, dependent: :destroy
  has_many :groups, through: :group_companies , source: :group

  has_many :main_groups, -> { where("group_companies.main_group = 't' ") }, through: :group_companies, source: :group
  # validates :amount_code, :prefix_name, presence: true
  
  # validates :name, presence: true, :uniqueness => { :case_sensitive => false, message: "Name must be unique" }, on: :create
  validates :name, presence: true
  attr_accessor :amount_code, :used, :prefix_name, :company_id

  def generate_code_of_company(invite_params, find_group = nil)
    puts "generate code"
    company_id = invite_params[:company_id]
    amount_code = invite_params[:amount_code]

    if company_id.present?
      InviteCode.add_more_invite_code(amount_code.to_i, company_id)
    else
      prefix_name = invite_params[:prefix_name]
      @company_name = invite_params[:name]
      if find_group.nil?
        group = create_group
      else
        group = find_group
      end
      InviteCode.create_invite_code(prefix_name, amount_code.to_i, self.id, group.id) 
    end 
  end

  def create_group
    Group.create(name: @company_name, authorize_invite: :everyone, public: false)
  end

  def self.open_spreadsheet(file)
    case File.extname(file.original_filename)
    when '.csv' then Roo::CSV.new(file.path)
    when '.xls' then Roo::Excel.new(file.path, file_warning: :ignore)
    when '.xlsx' then Roo::Excelx.new(file.path, file_warning: :ignore)
    else raise "Unknown file type: #{file.original_filename}"
    end
  end

  def as_json options={}
   {
      id: id,
      name: name
   }
  end

end

class Recommendation
  def initialize(member)
    @member = member
  end

  def get_member_recommendations
    @recommendations ||= find_brand
  end

  private

  def find_brand
    Member.with_member_type(:brand).order("fullname asc")
  end
  
  
end
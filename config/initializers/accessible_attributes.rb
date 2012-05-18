class ActiveRecord::Base
  attr_accessible :resource_type, :resource_id, :body
  attr_accessor :accessible
  
  private
  def mass_assignment_authorizer(role = :default)
    if accessible == :all
      self.class.protected_attributes
    else
      super + (accessible || [])
    end
  end
end
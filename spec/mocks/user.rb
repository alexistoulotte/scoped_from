class User < ActiveRecord::Base
  
  scope :enabled, :conditions => { :enabled => true }
  scope :search, lambda { |pattern|
    where('firstname like ? OR lastname LIKE ?', "%#{pattern}%", "%#{pattern}%")
  }
  
end
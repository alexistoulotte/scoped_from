class User < ActiveRecord::Base
  
  scope :enabled, :conditions => { :enabled => true }
  scope :search, lambda { |pattern|
    where('firstname like ? OR lastname LIKE ?', "%#{pattern}%", "%#{pattern}%")
  }
  scope :created_between, lambda { |after, before|
    where('created_at >= ? AND created_at <= ?', after, before)
  }
  
end
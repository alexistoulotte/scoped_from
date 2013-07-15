class User < ActiveRecord::Base

  scope :enabled, where(enabled: true)
  scope :search, lambda { |pattern|
    where('firstname LIKE ? OR lastname LIKE ?', "%#{pattern}%", "%#{pattern}%")
  }
  scope :created_between, lambda { |after, before|
    where('created_at >= ? AND created_at <= ?', after, before)
  }
  scope :latest, lambda {
    where('created_at >= ?', 1.week.ago)
  }

end
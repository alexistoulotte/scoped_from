class User < ActiveRecord::Base

  scope :enabled, where(enabled: true)
  scope :search, -> (pattern) { where('firstname LIKE ? OR lastname LIKE ?', "%#{pattern}%", "%#{pattern}%") }
  scope :created_between, -> (after, before) { where('created_at >= ? AND created_at <= ?', after, before) }
  scope :latest, -> { where('created_at >= ?', 1.week.ago) }

end
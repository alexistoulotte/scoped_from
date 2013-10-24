module UserMacro

  USERS = {}

  def create_user(label, attributes)
    USERS[label] = User.create!(attributes)
  end

  def users(label)
    USERS[label]
  end

end

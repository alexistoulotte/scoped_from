module UserMacro

  def create_user(label, attributes)
    @users ||= {}
    @users[label] = User.create!(attributes)
  end

  def users(label)
    (@users || {})[label]
  end

end

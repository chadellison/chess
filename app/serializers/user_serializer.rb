class UserSerializer
  class << self
    def serialize(user)
      {
        data: {
          type: 'user',
          id: user.id,
          attributes: {
            hashedEmail: user.hashed_email,
            token: user.token,
            firstName: user.first_name,
            lastName: user.last_name
          }
        }
      }
    end
  end
end

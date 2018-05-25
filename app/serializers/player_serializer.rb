class PlayerSerializer
  class << self
    def serialize(player_id)
      if player_id.present?
        player = User.find(player_id)
        {
          id: player_id,
          name: "#{player.first_name.capitalize} #{player.last_name.capitalize}",
          hashedEmail: player.hashed_email
        }
      else
        {
          name: Faker::Name.name,
          hashedEmail: Faker::Name.name
        }
      end
    end
  end
end

class PlayerSerializer
  class << self
    def serialize(player_id)
      if player_id.present?
        player = User.find(player_id)
        {
          id: player_id,
          name: player.format_name,
          hashedEmail: player.hashed_email
        }
      else
        {}
      end
    end
  end
end

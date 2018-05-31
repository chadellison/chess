class AiPlayerSerializer
  class << self
    def serialize(ai_player)
      if ai_player.present?
        {
          id: ai_player.id,
          color: ai_player.color,
          name: ai_player.name
        }
      else
        {}
      end
    end
  end
end

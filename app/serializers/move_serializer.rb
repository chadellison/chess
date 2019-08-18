class MoveSerializer
  class << self
    def serialize(move)
      move.to_json(include: { setup: { methods: :abstraction } })
    end

    def deserialize(move_data)
      move = JSON.parse(move_data).deep_symbolize_keys
      move[:setup][:abstraction] = move[:setup][:abstraction].map do |abstraction|
        Abstraction.new(abstraction)
      end

      move[:setup] = Setup.new(move[:setup])
      Move.new(move)
    end
  end
end

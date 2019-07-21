class MoveSerializer
  class << self
    def serialize(move)
      move.to_json(include: { setup: { methods: :signatures } })
    end

    def deserialize(move_data)
      move = JSON.parse(move_data).deep_symbolize_keys
      move[:setup][:signatures] = move[:setup][:signatures].map do |signature|
        Signature.new(signature)
      end

      move[:setup] = Setup.new(move[:setup])
      Move.new(move)
    end
  end
end

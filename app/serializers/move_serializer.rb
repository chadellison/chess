class MoveSerializer
  class << self
    def serialize(move)
      move.to_json(include: { setup: { methods: :abstractions } })
    end

    def deserialize(move_data)
      move = JSON.parse(move_data).deep_symbolize_keys
      move[:setup][:abstractions] = move[:setup][:abstractions].map do |abs|
        Abstraction.new(abs)
      end
      move[:setup] = Setup.new(move[:setup])
      Move.new(move)
    end
  end
end

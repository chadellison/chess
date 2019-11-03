class SetupSerializer
  class << self
    def serialize(setup)
      setup.to_json(include: :abstraction)
    end

    def deserialize(setup_data)
      setup = JSON.parse(setup_data).deep_symbolize_keys
      setup[:abstraction] = Abstraction.new(setup[:abstraction])
      Setup.new(setup)
    end
  end
end

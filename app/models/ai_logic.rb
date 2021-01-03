class AiLogic
  attr_reader :neural_network, :engine

  def initialize
    @neural_network = RubyNN::NeuralNetwork.new([12, 20, 26, 18, 1], 0.001)
    file_path = Rails.root + 'json/weights.json'
    begin
      json_weights = File.read(file_path)
      @neural_network.set_weights(JSON.parse(json_weights))
    rescue
      puts "FILE '#{file_path}' DOES NOT EXIST"
      @neural_network.initialize_weights
    end

    @engine = ChessValidator::Engine
  end

  def evaluate_position(fen_notation)
    turn = fen_notation.split[1]
    position = Position.create_position(fen_notation)
    inputs = create_abstractions(position['signature'])
    predictions = neural_network.calculate_prediction(inputs).last
    predictions.last
  end

  def create_abstractions(signature)
    position_data = PositionData.new(signature + ' 0 1')
    [
      Activity.create_abstraction(position_data),
      Material.create_abstraction(position_data),
      Attack.create_evade_abstraction(position_data.pieces),
      Attack.create_attack_abstraction(position_data),
      Castle.create_abstraction(position_data.fen_notation, position_data.turn),
      CenterCount.create_abstraction(position_data.pieces, position_data.next_pieces),
      King.create_abstraction(position_data),
      King.potential_mate_abstraction(position_data),
      King.create_threat_abstraction(position_data),
      Development.create_abstraction(position_data.all_pieces, position_data.turn),
      Pawn.create_center_abstraction(position_data.all_pieces, position_data.turn),
      Pawn.past_pawn_abstraction(position_data.all_pieces, position_data.turn),
    ]
  end

  def find_max_move_value(fen_notation)
    max = 0
    pieces_with_moves = engine.find_next_moves(fen_notation)
    pieces_with_moves.each do |piece|
      piece.valid_moves.each do |move|
        next_fen_notation = engine.move(piece, move, fen_notation)
        current_value = evaluate_position(next_fen_notation)
        max = current_value if current_value > max
      end
    end
    max
  end

  def analyze_position(fen_notation)
    pieces_with_next_moves = engine.find_next_moves(fen_notation)
    moves = []
    pieces_with_next_moves.each do |piece|
      piece.valid_moves.each do |move|
        next_fen_notation = engine.move(piece, move, fen_notation)

        evaluation = evaluate_position(next_fen_notation)

        moves << { move: piece.piece_type.capitalize + move, evaluation: evaluation }
      end
    end
    moves
  end

  def calculate_ratio(position, turn)
    if turn == 'w'
      wins = position['white_wins']
      losses = position['black_wins']
    else
      wins = position['black_wins']
      losses = position['white_wins']
    end
    half_draws = position['draws'] / 2.0
    numerator = wins + half_draws
    denominator = losses + half_draws

    if denominator == 0
      numerator
    elsif numerator == 0
      -denominator
    else
      (numerator / denominator) - 1
    end
  end
end

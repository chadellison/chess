class AiLogic
  attr_reader :neural_network, :engine

  def initialize
    @neural_network = RubyNN::NeuralNetwork.new([10, 20, 10, 1], 0.001)
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
    pieces_with_moves = engine.find_next_moves(fen_notation).sort_by(&:piece_type)
    inputs = create_abstractions(pieces_with_moves, position)

    # predictions = neural_network.calculate_prediction(inputs).last
    # predictions.last
    inputs
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

        # evaluation = abc123(pieces_with_next_moves, Position.create_position(fen_notation)).last
        evaluation = evaluate_position(next_fen_notation)

        # opponent_pieces_with_next_moves = engine.move(piece, move, next_fen_notation)
        # max_opponent_value = find_max_move_value(next_fen_notation)

        # evaluation = abc123(pieces, Position.create_position(fen_notation)).last

        # stockfish_data = Stockfish.analyze next_fen_notation, { :depth => 12 }
        # stockfish_evaluation = stockfish_data[:variations].first[:score] * -1
        # moves << { move: piece.piece_type.capitalize + move, stockfish_evaluation: stockfish_evaluation }
        moves << { move: piece.piece_type.capitalize + move, evaluation: evaluation }
      end
    end
    moves
  end

  def create_abstractions(pieces, position)
    fen_notation = position['signature'] + ' 0 1'

    if position['abstractions'].present?
      position['abstractions'].map do |abstraction|
        CacheService.hget(abstraction['type'], abstraction['signature'])
      end
    else
      all_pieces = ChessValidator::Engine.pieces(fen_notation).sort_by(&:piece_type)
      next_pieces = AbstractionHelper.next_pieces(fen_notation)
      [
        Activity.create_abstraction(pieces, next_pieces),
        Material.create_abstraction(all_pieces, pieces, fen_notation),
        Attack.create_evade_abstraction(pieces),
        Attack.create_attack_abstraction(pieces, next_pieces),
      ].sum
    end
  end

  def extract_outputs(position, turn)
    if turn == 'w'
      wins = position['white_wins']
      losses = position['black_wins']
    else
      wins = position['black_wins']
      losses = position['white_wins']
    end
    [wins, losses, position['draws']]
  end
end

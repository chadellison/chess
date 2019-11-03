class StockfishIntegration
  attr_reader :game, :engine, :pgn_logic

  def initialize(game)
    @game = game
    @engine = Stockfish::Engine.new
    @pgn_logic = PgnLogic.new
  end

  def find_stockfish_move
    engine.multipv(3)
    begin
      stockfish_result = engine.analyze(pgn_logic.convert_to_fen(game.notation), { depth: 12 })
    rescue
      binding.pry
    end
    stockfish_result.split('bestmove').last.split('ponder').first.strip
  end

  def stockfish_color(game_number)
    game_number.even? ? 'white' : 'black'
  end

  def find_upgraded_type(stockfish_letter)
    if stockfish_letter.present?
      { q: 'queen', r: 'rook', b: 'bishop', n: 'knight' }[stockfish_letter.to_sym]
    else
      ''
    end
  end
end

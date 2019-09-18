class StockfishIntegration
  attr_reader :fen_notation, :engine

  def initialize(game)
    @engine = Stockfish::Engine.new
    @fen_notation = FenNotation.new(game)
  end

  def find_stockfish_move
    engine.multipv(3)
    stockfish_result = engine.analyze(fen_notation.find_fen_notation, { depth: 12 })
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

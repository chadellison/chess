class StockfishIntegration
  attr_reader :game
  attr_accessor :engine

  def initialize(game)
    @game = game
    @engine = Stockfish::Engine.new('lib/stockfish-9-mac/Mac/stockfish-9-bmi2')
  end

  def find_stockfish_move
    engine.multipv(3)
    stockfish_result = engine.analyze(game.find_fen_notation, { depth: 12 })
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

class StockfishMoveJob < ApplicationJob
  queue_as :default

  def perform(game)
    stockfish = StockfishIntegration.new(game)

    stockfish_move = stockfish.find_stockfish_move
    position_index = game.find_piece_by_position(stockfish_move[0..1]).position_index
    upgraded_type = stockfish.find_upgraded_type(stockfish_move[4])

    game.move(position_index, stockfish_move[2..3], upgraded_type)
  end
end

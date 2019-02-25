class Game < ApplicationRecord
  has_many :moves, dependent: :destroy
  has_many :chat_messages, dependent: :destroy
  belongs_to :ai_player, optional: true, dependent: :destroy

  include NotationLogic
  include FenNotationLogic
  include BoardLogic
  include AiLogic
  include PieceHelper

  scope :winning_games, ->(win) { where(outcome: win) }
  scope :user_games, ->(user_id) { where(white_player: user_id).or(where(black_player: user_id))}
  scope :similar_games, ->(move_notation) { where('notation LIKE ?', "#{move_notation}%") }

  scope :find_open_games, (lambda do |user_id|
    where.not(white_player: user_id)
         .or(where.not(black_player: user_id))
         .where(status: 'awaiting player')
  end)

  def self.create_user_game(user, game_params)
    game = Game.new(game_type: game_params[:game_type])
    game_params[:color] == 'white' ? game.white_player = user.id : game.black_player = user.id

    if game_params[:game_type] == 'human vs machine'
      machine_player = create_ai_player(game_params[:color])
      game.ai_player = machine_player
      game.status = 'active'
    else
      game.status = 'awaiting player'
    end
    game.save
    game.ai_move if game.ai_turn?
    game
  end

  def self.create_ai_player(color)
    if color == 'white'
      ai_color = 'black'
    else
      ai_color = 'white'
    end
    AiPlayer.create(color: ai_color, name: Faker::Name.name)
  end

  def move(position_index, new_position, upgraded_type = '')
    update_notation(position_index, new_position, upgraded_type)
    piece = find_piece_by_index(position_index)
    update_game(piece, new_position, upgraded_type)
    handle_human_game if game_type.include?('human')
    return handle_outcome if game_over?(pieces, current_turn)
    ai_move if ai_turn?
  end

  def handle_human_game
    GameEventBroadcastJob.perform_later(self)
    reload_pieces
  end

  def handle_move(move_value, upgraded_type = '')
    position_index = move_value.to_i
    new_position = move_value[-2..-1]

    update_notation(move_value.to_i, new_position, upgraded_type)
    piece = find_piece_by_index(position_index)
    update_game(piece, new_position, upgraded_type)
    handle_human_game if game_type.include?('human')
    return handle_outcome if game_over?(pieces, current_turn)
  end

  def game_over?(pieces, game_turn)
    checkmate?(pieces, game_turn) || stalemate?(pieces, game_turn)
  end

  def handle_outcome
    if checkmate?(pieces, current_turn)
      outcome = current_turn == 'black' ? 1 : -1
    else
      outcome = 0
    end
    update(outcome: outcome)
    GameEventBroadcastJob.perform_later(self) if game_type.include?('human')
    propogate_results if game_type == 'machine vs machine' && outcome != 0
  end

  def join_user_to_game(user_id)
    if white_player.blank?
      update(white_player: user_id, status: 'active')
    else
      update(black_player: user_id, status: 'active')
    end
    GameEventBroadcastJob.perform_later(self)
  end

  def ai_turn?
    ai_player.present? && current_turn == ai_player.color
  end

  def current_turn
    moves.count.even? ? 'white' : 'black'
  end

  def opponent_color
    current_turn == 'white' ? 'black' : 'white'
  end

  def machine_vs_machine
    until outcome.present? do
      ai_move
      update(outcome: 0) if moves.count > 400
      puts moves.order(:move_count).last.value
      puts '******************'
    end
  end

  def propogate_results
    moves.each do |move|

      setup = move.setup
      setup.outcomes.create(value: outome)

      setup.signatures.each do |signature|
        signature.update(rank: signature.rank + outcome)
      end
    end
  end
end

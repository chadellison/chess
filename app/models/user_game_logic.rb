class UserGameLogic
  def create_user_game(user, game_params)
    game = Game.new(game_type: game_params[:game_type])
    game_params[:color] == 'white' ? game.white_player = user.id : game.black_player = user.id

    if ['human vs machine', 'human vs stockfish'].include?(game_params[:game_type])
      machine_player = create_ai_player(game_params[:color])
      game.ai_player = machine_player
      game.status = 'active'
    else
      game.status = 'awaiting player'
    end
    game.save
    handle_first_move(game) if game.ai_turn?(game.current_turn)
    game
  end

  def handle_first_move(game)
    if game.game_type == 'human vs stockfish'
      StockfishMoveJob.perform_later(game)
    else
      AiMoveJob.perform_later(game)
    end
  end

  def create_ai_player(color)
    if color == 'white'
      ai_color = 'black'
    else
      ai_color = 'white'
    end
    AiPlayer.create(color: ai_color, name: Faker::Name.name)
  end
end

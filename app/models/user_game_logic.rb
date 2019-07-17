class UserGameLogic
  def create_user_game(user, game_params)
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
    turn = game.current_turn
    game.ai_logic.ai_move(turn) if game.ai_turn?(turn)
    game
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

require 'rails_helper'

RSpec.describe Game, type: :model do
  it 'has many pieces' do
    piece = Piece.new(
      piece_type: 'rook',
      color: 'black',
      position: 'a2'
    )

    game = Game.new
    game.pieces << piece

    expect(game.pieces).to eq [piece]
  end

  it 'has many moves' do
    move = Move.new

    game = Game.new
    game.moves << move

    expect(game.moves).to eq [move]
  end

  describe 'current_setup' do
    context 'when no moves are present' do
      it 'returns the games current setup' do
        game = Game.create

        expected = '1a8.2b8.3c8.4d8.5e8.6f8.7g8.8h8.9a7.10b7.11c7.12d7.13e7.14f7.15g7.16h7.17a2.18b2.19c2.20d2.21e2.22f2.23g2.24h2.25a1.26b1.27c1.28d1.29e1.30f1.31g1.32h1'

        expect(game.current_setup).to eq expected
      end
    end

    context 'when moves are present' do
      it 'returns the games current setup' do
        game = Game.create

        game.move(20, 'd4')
        game.pieces.reload
        expected = '1a8.2b8.3c8.4d8.5e8.6f8.7g8.8h8.9a7.10b7.11c7.12d7.13e7.14f7.15g7.16h7.17a2.18b2.19c2.20d4.21e2.22f2.23g2.24h2.25a1.26b1.27c1.28d1.29e1.30f1.31g1.32h1'

        expect(game.current_setup).to eq expected
      end
    end
  end

  describe 'move' do
    it 'updates the moved piece\'s position and has_moved property' do
      game = Game.create
      game.move(9, 'a3')

      actual = game.pieces.find_by(position_index: 9)
      expect(actual.position).to eq 'a3'
      expect(actual.has_moved).to be true
    end

    it 'calls create_notation' do
      expect_any_instance_of(Game).to receive(:update_notation)
        .with(9, 'a3', '')
      game = Game.create
      game.move(9, 'a3')
    end

    it 'calls update_board' do
      expect_any_instance_of(Game).to receive(:update_board)
      game = Game.create
      game.move(9, 'a3')
    end

    it 'calls update_piece' do
      game = Game.create
      piece = game.pieces.find_by(position_index: 9)
      expect_any_instance_of(Game).to receive(:update_piece)
        .with(piece, 'a3', '')
      game.move(9, 'a3')
    end
  end

  describe 'after_commits' do
    describe 'add_pieces' do
      it 'adds 32 pieces to a game' do
        expect { Game.create }.to change { Piece.count }.by(32)
      end
    end
  end

  describe 'scopes' do
    describe '#similar_games' do
    # let(:notation) { ' 9:a6 18:b4' }
    #
    # before do
    #   3.times do |n|
    #     game = Game.new
    #     game.save(validate: false)
    #     game.update_attribute(:robot, true)
    #     game.update_attribute(:move_signature, move_signature) if n.even?
    #   end
    # end
    #
    # context 'when the move signature matches previous games' do
    #   it 'returns games that match that game\'s move signature' do
    #     expect(Game.similar_games(move_signature).count).to eq 2
    #     expect(Game.similar_games(move_signature).map(&:move_signature))
    #       .to eq [move_signature, move_signature]
    #   end
    # end
    #
    # context 'when the move signature matches previous games\' beginnings' do
    #   it 'returns games that match that game\'s move signature' do
    #     expect(Game.similar_games(' 9:a6').count).to eq 2
    #     expect(Game.similar_games(move_signature).map(&:move_signature))
    #       .to eq [move_signature, move_signature]
    #   end
    # end

  #   describe '#winning_games' do
  #   let!(:win) {
  #     Game.new(
  #       outcome: 1,
  #       robot: true
  #     )
  #   }
  #
  #   let!(:draw) {
  #     Game.create(
  #       challengedEmail: Faker::Internet.email,
  #       challengedName: Faker::Name.name,
  #       challengerColor: 'white',
  #       outcome: 0
  #     )
  #   }
  #
  #   it 'returns winning games of the given color' do
  #     win.save(validate: false)
  #     expect(Game.winning_games(1, 'white').last).to eq win
  #     expect(Game.winning_games(1, 'white').count).to eq 1
    end
  end
end

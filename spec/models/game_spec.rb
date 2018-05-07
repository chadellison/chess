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

  it 'has many game_setups' do
    game_setup = GameSetup.new

    game = Game.new
    game.game_setups << game_setup

    expect(game.game_setups).to eq [game_setup]
  end

  it 'has many setups' do
    setup = Setup.new

    game = Game.new
    game.setups << setup

    expect(game.setups).to eq [setup]
  end

  describe 'move' do
    it 'updates the moved piece\'s position' do
      game = Game.create
      game.move(9, 'a3')

      actual = game.pieces.find_by(position_index: 9).position
      expect(actual).to eq 'a3'
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
  end


  describe 'update_board' do
    it 'creates a move position_signature of the current board positions' do
      game = Game.create
      game.update_board

      expected = '1a8.2b8.3c8.4d8.5e8.6f8.7g8.8h8.9a7.10b7.11c7.12d7.13e7.14f7.15g7.16h7.17a2.18b2.19c2.20d2.21e2.22f2.23g2.24h2.25a1.26b1.27c1.28d1.29e1.30f1.31g1.32h1'

      actual = game.setups.first.position_signature
      expect(actual).to eq expected
    end

    it 'creates a setup on the game if it does not already exist' do
      game = Game.create

      expect { game.update_board }.to change { game.setups.count }.by(1)
    end
  end

  describe 'update_notation' do
    it 'calls create_notation' do
      allow_any_instance_of(Game).to receive(:add_pieces)

      expect_any_instance_of(Game).to receive(:create_notation)
        .with(9, 'a3', '')

      game = Game.create
      game.update_notation(9, 'a3', '')
    end

    it 'updates the game\'s notation' do
      allow_any_instance_of(Game).to receive(:create_notation)
        .and_return('123')

      game = Game.create(notation: 'abc')
      game.update_notation(9, 'a3', '')

      expect(game.notation).to eq 'abc123'
    end
  end

  describe 'after_commits' do
    describe '#add_pieces' do
      it 'adds 32 pieces to a game' do
        expect { Game.create }.to change { Piece.count }.by(32)
      end
    end
  end

  describe 'notation_logic_methods' do
    describe '#create_notation' do
      let(:game) { Game.create }

      context 'for a pawn move' do
        it 'returns the notation' do
          actual = game.create_notation(20, 'd4', '')
          expect(actual).to eq 'd4.'
        end
      end

      context 'when a pawn kills another piece' do
        it 'returns the notation' do
          game.pieces.find_by(position: 'e7').update(position: 'e5')
          game.pieces.find_by(position: 'd2').update(position: 'd4')
          actual = game.create_notation(20, 'e5', '')
          expect(actual).to eq 'dxe5.'
        end
      end

      context 'for a castle king side' do
        xit 'test' do
        end
      end

      context 'for a castle queen side' do
        xit 'test' do
        end
      end

      context 'for a knight' do
        xit 'test' do
        end
      end

      context 'for a knight when both knights can move on a given position' do
        xit 'test' do
        end
      end

      context 'for a rook when two rooks are on the same column' do
        xit 'test' do
        end
      end

      context 'for a rook when two rooks are on the same row' do
        xit 'test' do
        end
      end

      context 'for a crossed pawn' do
        xit 'test' do
        end
      end

      context 'for a crossed pawn that captures a piece' do
        xit 'test' do
        end
      end
    end

    describe 'start_notation' do
      xit 'test' do
      end
    end

    describe 'capture_notation' do
      xit 'test' do
      end
    end

    describe 'piece_code' do
      xit 'test' do
      end
    end

    describe 'castle_notation' do
      xit 'test' do
      end
    end

    describe '#matching_piece' do
      xit 'test' do
      end
    end

    describe '#index_is_unique?' do
      xit 'test' do
      end
    end
  end
end

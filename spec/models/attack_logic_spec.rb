require 'rails_helper'

RSpec.describe AttackLogic, type: :model do
  describe 'create_signature' do
    describe 'when the black queen is attacked and it is white\'s turn' do
      it 'returns 9' do
        move = Move.new
        game_pieces = Marshal.load(Marshal.dump(PIECES))
        black_queen = game_pieces.detect { |piece| piece.position_index == 4 }
        white_knight = game_pieces.detect { |piece| piece.position_index == 26 }

        black_queen.position = 'd5'
        white_knight.position = 'c3'
        white_knight.enemy_targets = [4]
        game_data = GameData.new(move, game_pieces, 'white', 0)

        expect(AttackLogic.create_signature(game_data)).to eq 9
      end
    end

    describe 'when the black queen is attacked and it is black\'s turn' do
      it 'returns 0' do
        move = Move.new
        game_pieces = Marshal.load(Marshal.dump(PIECES))
        black_queen = game_pieces.detect { |piece| piece.position_index == 4 }
        white_knight = game_pieces.detect { |piece| piece.position_index == 26 }

        black_queen.position = 'd5'
        white_knight.position = 'c3'
        white_knight.enemy_targets = [4]
        game_data = GameData.new(move, game_pieces, 'black', 0)

        expect(AttackLogic.create_signature(game_data)).to eq 0
      end
    end

    describe 'when the black queen is attacked by a knight and is defended' do
      it 'returns 6' do
        move = Move.new
        game_pieces = Marshal.load(Marshal.dump(PIECES))
        black_queen = game_pieces.detect { |piece| piece.position_index == 4 }
        white_knight = game_pieces.detect { |piece| piece.position_index == 26 }
        black_knight = game_pieces.detect { |piece| piece.position_index == 7 }

        black_queen.position = 'd5'
        black_knight.position = 'f6'
        white_knight.position = 'c3'
        white_knight.enemy_targets = [4]
        game_data = GameData.new(move, game_pieces, 'white', 0)

        expect(AttackLogic.create_signature(game_data)).to eq 6
      end
    end

    describe 'when the black queen is attacked by a queen and is defended' do
      it 'returns 0' do
        move = Move.new
        game_pieces = Marshal.load(Marshal.dump(PIECES))
        black_queen = game_pieces.detect { |piece| piece.position_index == 4 }
        white_queen = game_pieces.detect { |piece| piece.position_index == 28 }
        black_knight = game_pieces.detect { |piece| piece.position_index == 7 }

        black_queen.position = 'd5'
        black_knight.position = 'f6'
        white_queen.position = 'd4'
        white_queen.enemy_targets = [4]
        game_data = GameData.new(move, game_pieces, 'white', 0)

        expect(AttackLogic.create_signature(game_data)).to eq 0
      end
    end
  end
end

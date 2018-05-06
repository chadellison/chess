class Piece < ApplicationRecord
  belongs_to :game, optional: true
end

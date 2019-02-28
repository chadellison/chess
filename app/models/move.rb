class Move < ApplicationRecord
  belongs_to :game
  belongs_to :setup, optional: true
end

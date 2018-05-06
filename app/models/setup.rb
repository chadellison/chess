class Setup < ApplicationRecord
  has_many :game_setups
  has_many :games, through: :game_setups
end

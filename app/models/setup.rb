class Setup < ApplicationRecord
  validates_uniqueness_of :position_signature

  scope :white_wins, -> { where('rank > ?', 0) }
  scope :black_wins, -> { where('rank < ?', 0) }
end

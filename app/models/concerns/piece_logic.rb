module PieceLogic
  extend ActiveSupport::Concern

  def find_piece_code
    color == 'white' ? self.class.to_s[0] : self.class.to_s[0].downcase
  end
end

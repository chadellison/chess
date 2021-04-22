class PositionSearch
  def index
    PositionIndex
  end

  # PositionIndex.query(prefix: {signature: 'r2q1rk1z1p1n1pppzp1b1pb2z8z2NB4z1P2P3zP1Q'}).to_a
  def search(prefix)
    index.query(prefix: {signature: prefix}).to_a
  end
end

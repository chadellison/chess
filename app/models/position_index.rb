class PositionIndex < Chewy::Index
  settings analysis: {
    analyzer: {
      signature: {
        tokenizer: 'standard',
        filter: ['asciifolding']
      },
    }
  }

  index_scope Hash
  field :white_wins
  field :black_wins
  field :draws
  field :signature, analyzer: 'signature'
end

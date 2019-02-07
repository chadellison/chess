require 'rails_helper'

RSpec.describe Setup, type: :model do
  it 'validates_uniqueness_of position_signature' do
    original_setup = Setup.create(position_signature: 'abc')
    setup = Setup.new(position_signature: 'abc')
    expect(setup.valid?).to be false
    expect(setup.errors.messages[:position_signature].first).to eq 'has already been taken'
  end
end

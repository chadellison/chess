require 'rails_helper'

RSpec.describe AttackSignature, type: :model do
  it 'validates_presence_of signature' do
    attack_signature = AttackSignature.new
    expect(attack_signature.valid?).to be false
    expect(attack_signature.errors.messages[:signature].first).to eq 'can\'t be blank'
  end

  it 'validates_uniqueness_of signature' do
    original_signature = AttackSignature.create(signature: 'abc')
    attack_signature = AttackSignature.new(signature: 'abc')
    expect(attack_signature.valid?).to be false
    expect(attack_signature.errors.messages[:signature].first).to eq 'has already been taken'
  end

  it 'has many setups' do
    attack_signature = AttackSignature.new
    setup = Setup.new
    attack_signature.setups << setup
    expect(attack_signature.setups).to eq [setup]
  end
end

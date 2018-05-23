require 'rails_helper'

RSpec.describe User, type: :model do
  let(:email) { Faker::Internet.email }
  let(:password) { 'password' }
  let(:first_name) { Faker::Name.first_name }
  let(:last_name) { Faker::Name.last_name }

  it 'validates the presence of an email' do
    user = User.create(password: password,
                       first_name: first_name,
                       last_name: last_name)

    expect(user.valid?).to be false
    user.update(email: email)
    expect(user.valid?).to be true
  end

  it 'validates the uniqueness of an email' do
    user = User.create(email: email,
                       password: 'password2',
                       first_name: Faker::Name.first_name,
                       last_name: Faker::Name.last_name)

    user = User.create(email: email,
                       password: password,
                       first_name: first_name,
                       last_name: last_name)

    expect(user.valid?).to be false
  end

  it 'validates the presence of a password' do
    user = User.create(email: email,
                       first_name: first_name,
                       last_name: last_name)

    expect(user.valid?).to be false

    user.update(password: password)
    expect(user.valid?).to be true
  end

  it 'validates the presence of a first name' do
    user = User.create(email: email,
                       password: password,
                       last_name: last_name)

    expect(user.valid?).to be false
    user.update(first_name: first_name)
    expect(user.valid?).to be true
  end

  it 'validates the presence of a last name' do
    user = User.create(email: email,
                       password: password,
                       first_name: first_name)

    expect(user.valid?).to be false
    user.update(last_name: last_name)
    expect(user.valid?).to be true
  end

  context 'before_save' do
    describe 'hashed_email' do
      it 'returns a hash of the user\'s email' do
        user = User.create(
          email: Faker::Internet.email,
          password: Faker::Internet.password,
          first_name: first_name,
          last_name: last_name
        )

        expect(user.hashed_email).to eq Digest::MD5.hexdigest(user.email)
      end
    end

    describe 'downcase_email' do
      it 'downcases the user\'s email' do
        user = User.create(
          email: 'CapitalEmail.com',
          password: Faker::Internet.password,
          first_name: first_name,
          last_name: last_name
        )

        expect(user.downcase_email).to eq 'capitalemail.com'
      end
    end
  end
end

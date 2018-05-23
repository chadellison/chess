require 'rails_helper'

RSpec.describe Api::V1::AuthenticationController, type: :controller do
  describe '#create' do
    context 'with the proper email and password' do
      let(:email) { Faker::Internet.email }
      let(:first_name) { Faker::Name.first_name }
      let(:last_name) { Faker::Name.last_name }

      let!(:user) {
        User.create(email: email,
                    password: 'password',
                    first_name: first_name,
                    last_name: last_name)
      }

      let(:params) { { credentials: { email: email, password: 'password' } } }

      it 'returns the user\'s token and hashed_email, but not the email or password' do
        post :create, params: params, format: :json

        expect(response.status).to eq 201
        expect(JSON.parse(response.body)['data']['attributes']['hashedEmail'])
          .to eq user.hashed_email
        expect(JSON.parse(response.body)['data']['attributes']['token'])
          .to be_present
        expect(JSON.parse(response.body)['data']['attributes']['email'])
          .not_to be_present
        expect(JSON.parse(response.body)['data']['attributes']['password'])
          .not_to be_present
      end
    end

    context 'with improper credentials' do
      let(:email) { Faker::Internet.email }
      let!(:user) { User.create(email: email, password: 'password') }
      let(:bad_password) { Faker::Name.name }
      let(:params) { { credentials: { email: email, password: bad_password } } }

      it 'returns a 404 status and an error' do
        get :create, params: params, format: :json

        expect(response.status).to eq 404
        expect(JSON.parse(response.body)['errors']).to eq 'Invalid Credentials'
      end
    end

    context 'with an uppercase email' do
      let(:email) { Faker::Internet.email }
      let(:first_name) { Faker::Name.first_name }
      let(:last_name) { Faker::Name.last_name }

      let!(:user) do
        User.create(email: email,
                    password: 'password',
                    first_name: first_name,
                    last_name: last_name)
      end

      let(:params) do
        { credentials: { email: email.upcase,
                         password: 'password' } }
      end

      it 'finds the email' do
        post :create, params: params, format: :json

        expect(response.status).to eq 201
        expect(JSON.parse(response.body)['data']['attributes']['hashedEmail'])
          .to eq user.hash_email
        expect(JSON.parse(response.body)['data']['attributes']['firstName'])
          .to eq first_name
        expect(JSON.parse(response.body)['data']['attributes']['lastName'])
          .to eq last_name
        expect(JSON.parse(response.body)['data']['attributes']['token'])
          .to be_present
      end
    end
  end
end

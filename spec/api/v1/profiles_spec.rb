require 'rails_helper'

describe 'Profiles API', type: :request do
  let(:headers) { { "CONTENT_TYPE" => "application/json",
                    "ACCEPT" => 'application/json' } }

  describe 'GET /api/v1/profiles/me' do
    it_behaves_like 'API Authorizable' do
      let(:api_path) { '/api/v1/profiles/me' }
      let(:method) { :get }
    end

    context 'authorized' do
      let(:me) { create(:user) }
      let(:access_token) { create(:access_token, resource_owner_id: me.id) }
      let(:profile_response) { json['user'] }

      before { get '/api/v1/profiles/me', params: { access_token: access_token.token }, headers: headers }
      
      it 'returns 200 status' do
        expect(response).to be_successful
      end

      it 'returns all public fields' do
        %w[id email admin created_at updated_at].each do |attr|
          expect(profile_response[attr]).to eq me.send(attr).as_json
        end
      end

      it "doesn't return private fields" do
        %w[password encrypted_password].each do |attr|
          expect(profile_response[attr]).to_not eq have_key(attr)
        end
      end
    end
  end

  describe 'GET /api/v1/profiles' do
    let(:api_path) { api_v1_profiles_path }
    it_behaves_like 'API Authorizable' do
      let(:method) { :get }
    end

    context 'authorized' do
      let(:me) { create(:user) }
      let!(:other_users) { create_list(:user, 5) }
      let(:access_token) { create(:access_token, resource_owner_id: me.id) }
      let(:everyone_except_me_response) { json['users'].first }

      before { get api_path, params: { access_token: access_token.token }, headers: headers }

      it 'returns list of all users except me' do
        expect(json['users'].size).to eq other_users.size
        expect(json['users'].map { |user_hash| user_hash['id'] }).to_not include(me.id)
      end

      it 'returns all public fields' do 
        %w[id email created_at updated_at].each do |attr|
          expect(everyone_except_me_response[attr]).to eq other_users.first.send(attr).as_json
        end
      end

      it "doesn't return private fields" do
        %w[password encrypted_password].each do |attr|
          expect(everyone_except_me_response).to_not eq have_key(attr)
        end
      end
    end
  end
end

require 'rails_helper'
shared_examples_for 'voted' do |resource_name|
  let(:user) { create(:user) }

  describe 'POST #upvote' do
    before do
      login(user)
    end

    context 'by valid user who is allowed to vote' do
      let!(:resource) { create(resource_name) }

      it 'upvotes the resource' do
        # Expect there to exist a on: :member route
        expect{ post(:upvote, params: { id: resource.id }) }.to change(resource, :rating).by(1)
      end

      it 'answers back JSON' do
        post(:upvote, params: { id: resource.id })
        expect(response.header['Content-Type']).to include 'application/json'
      end

      it 'answers back JSON of specified format' do
        post(:upvote, params: { id: resource.id })
        expect(response.body).to eq({ id: resource.id, rating: resource.rating, resource_type: resource.class.name }.to_json)
      end
    end

    context 'by invalid user who is not allowed to vote' do
      let!(:resource_by_user) { create(resource_name, author: user) }

      it 'does not upvote the question' do
        expect{ post(:upvote, params: { id: resource_by_user.id }) }.to_not change(resource_by_user, :rating)
      end

      it 'answers with unprocessible_entity(422)' do
        post(:upvote, params: { id: resource_by_user.id })
        expect(response.status).to eq 422
      end
    end
  end

  describe 'POST #downvote' do
    before do
      login(user)
    end

    context 'by valid user who is allowed to vote' do
      let!(:resource) { create(resource_name) }

      it 'downvotes the resource' do
        # Expect there to exist a on: :member route
        expect{ post(:downvote, params: { id: resource.id }) }.to change(resource, :rating).by(-1)
      end

      it 'answers back JSON' do
        post(:downvote, params: { id: resource.id })
        expect(response.header['Content-Type']).to include 'application/json'
      end

      it 'answers back JSON of specified format' do
        post(:downvote, params: { id: resource.id })
        expect(response.body).to eq({ id: resource.id, rating: resource.rating, resource_type: resource.class.name }.to_json)
      end
    end

    context 'by invalid user who is not allowed to vote' do
      let!(:resource_by_user) { create(resource_name, author: user) }

      it 'does not downvote the question' do
        expect{ post(:downvote, params: { id: resource_by_user.id }) }.to_not change(resource_by_user, :rating)
      end

      it 'answers with unprocessible_entity(422)' do
        post(:upvote, params: { id: resource_by_user.id })
        expect(response.status).to eq 422
      end
    end
  end

  describe 'DELETE #cancel_vote' do
    before { login(user) }

    context 'by valid user who is allowed to vote' do
      let!(:resource) { create(resource_name) }

      before do
        post(:upvote, params: { id: resource.id })
      end

      it 'deletes the previous vote by the user' do
        expect{ delete(:cancel_vote, params: { id: resource.id }).to change(resource.votes, :count).by(-1) }
      end

      it 'answers with JSON' do
        delete(:cancel_vote, params: { id: resource.id })
        expect(response.header['Content-Type']).to include 'application/json'
      end

      it 'answers back with JSON of correct format' do
        delete(:cancel_vote, params: { id: resource.id })
        resource.reload
        expect(response.body).to eq({ id: resource.id, rating: resource.rating, resource_type: resource.class.name }.to_json)
      end
    end

    context 'by invalid user who is not allowed to vote' do
      let!(:resource_by_user) { create(resource_name, author: user) }

      it 'does not delete the previous vote by the user' do
        expect{ delete(:cancel_vote, params: { id: resource_by_user.id })}.to_not change(resource_by_user.votes, :count)
      end

      it 'answers with unprocessible_entity(422)' do
        post(:upvote, params: { id: resource_by_user.id })
        expect(response.status).to eq 422
      end
    end
  end
end


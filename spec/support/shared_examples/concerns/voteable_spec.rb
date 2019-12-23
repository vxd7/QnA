require 'rails_helper'
shared_examples_for 'voteable' do
  describe 'associations' do
    it { should have_many(:votes).dependent(:destroy) }
  end

  let!(:user) { create(:user) }

  describe '#upvote' do
    it 'should vote up by correct user for the resource' do
      resource.upvote(user)
      expect(resource.votes.first.user).to eq user
    end

    it 'should create +1 vote for the resource' do
      resource.upvote(user)
      expect(resource.votes.first.value).to eq(1)
    end
  end

  describe '#downvote' do
    it 'should vote up by correct user for the resource' do
      resource.upvote(user)
      expect(resource.votes.first.user).to eq user
    end

    it 'should create -1 vote for the resource' do
      resource.downvote(user)
      expect(resource.votes.first.value).to eq(-1)
    end
  end

  describe '#rating' do
    it 'should be equal to 0 when there is no votes' do
      expect(resource.rating).to eq(0)
    end

    it 'should increase by upvote' do
      expect { resource.upvote(user) }.to change(resource, :rating).by(1)
    end

    it 'should decrease by downvote' do
      expect { resource.downvote(user) }.to change(resource, :rating).by(-1)
    end
  end

  describe '#has_votes?' do
    it 'should be true when there are upvotes' do
      resource.upvote(user)
      expect(resource).to have_votes
    end

    it 'should be true when there are downvotes' do
      resource.downvote(user)
      expect(resource).to have_votes
    end

    it 'should be false when there are no votes' do
      expect(resource).to_not have_votes
    end
  end
end

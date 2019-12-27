require 'rails_helper'
shared_examples_for 'voteable' do |resource_name|
  describe 'associations' do
    it { should have_many(:votes).dependent(:destroy) }
  end

  let!(:user) { create(:user) }
  let!(:resource) { create(resource_name) }

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

  describe '#vote_by_user' do
    it "should return user's vote when there is a vote" do
      resource.upvote(user)
      expect(resource.vote_by_user(user)).to eq resource.votes.find_by(user: user)
    end

    it 'should not return anything when there is no user vote' do
      expect(resource.vote_by_user(user)).to eq nil
    end
  end

  describe '#voteable_by?' do
    let!(:resource_by_user) { create(resource_name, author: user) }

    it 'should be true when user is not an author of the resource and has no votes for this resource' do
      expect(resource).to be_voteable_by(user)
    end

    it 'should be false when user is an author of the resource' do
      expect(resource_by_user).to_not be_voteable_by(user)
    end

    it 'should be false when user is not an author of the resource but has already voted for the resource' do
      resource.upvote(user)
      expect(resource).to_not be_voteable_by(user)
    end

    it 'should be false when user is not an author of the resource but has already voted for the resource' do
      resource.downvote(user)
      expect(resource).to_not be_voteable_by(user)
    end
  end
end

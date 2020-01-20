require 'rails_helper'

RSpec.describe Question, type: :model do
  it_should_behave_like 'voteable', :question
  it_should_behave_like 'commentable', :question

  describe 'associations' do
    it { should have_many(:answers).dependent(:destroy) }
    it { should have_many(:links).dependent(:destroy) }
    it { should belong_to(:author).class_name(:User) }
    it { should have_one(:reward).dependent(:destroy) }
    it { should have_many(:subscriptions).dependent(:destroy) }
    it { should have_many(:users_subscribed).through(:subscriptions).source(:user) }
  end

  describe 'attribute validations' do
    context 'presence validations' do
      it { should validate_presence_of :title }
      it { should validate_presence_of :body }
    end

    it { should accept_nested_attributes_for(:links).allow_destroy(true) }
    it { should accept_nested_attributes_for(:reward).allow_destroy(true) }

    it 'have many attached files' do
      expect(Question.new.files).to be_an_instance_of(ActiveStorage::Attached::Many)
    end
  end

  describe 'reputation' do
    let(:question) { build(:question) }

    it 'calls ReputationJob' do
      expect(ReputationJob).to receive(:perform_later).with(question)
      question.save!
    end
  end

  describe '#subscribed?' do
    let!(:user) { create(:user) }
    let(:question) { create(:question) } 
    context 'not subscribed user' do 
      it 'should be false' do
        expect(question.subscribed?(user)).to be false
      end
    end

    context 'subscribed_user' do
      let!(:subscription) { create(:subscription, question: question, user: user) }
      it 'should be true' do
        expect(question.subscribed?(user)).to be true
      end
    end
  end

  describe '#subscribe' do
    let!(:user) { create(:user) }
    let(:question) { create(:question) }

    context 'not subscribed user' do
      it 'creates the subscription' do
        question.subscribe(user)
        question.reload
        expect(question.users_subscribed).to include user
      end
    end

    context 'already subscribed user' do
      it 'does not subscribe them again' do
        question.subscribe(user)
        question.reload
        expect{question.subscribe(user)}.to_not change{ question.users_subscribed }
      end
    end
  end

  describe '#ubsubscribe' do
    let!(:user) { create(:user) }
    let(:question) { create(:question) }
    context 'subscribed user' do
      before { question.subscribe(user) }

      it 'unsubscribes them' do
        question.unsubscribe(user)
        question.reload
        expect(question.users_subscribed).to_not include user
      end
    end
  end
end

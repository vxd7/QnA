require 'rails_helper'

RSpec.describe Answer, type: :model do
  describe 'associations' do
    it { should belong_to :question }
    it { should belong_to(:author).class_name(:User) }
    it { should have_many(:links).dependent(:destroy) }
  end

  describe 'attribute validations' do
    it { should validate_presence_of :body }
    it { should accept_nested_attributes_for(:links).allow_destroy(true) }

    describe 'best answer validation if answer is choosen as best answer' do
      let!(:answer) { create(:answer, best_answer: true) }
      it { should validate_uniqueness_of(:best_answer).scoped_to(:question_id)}
    end

    # We want there to be only one answer marked as best for the given question
    # but multiple NOT BEST answers for the given question
    describe 'best answer validation if answer is choosen as NOT best answer' do
      let!(:answer) { create(:answer, best_answer: false) }
      it { should_not validate_uniqueness_of(:best_answer).scoped_to(:question_id)}
    end

    it 'have many attached files' do
      expect(Question.new.files).to be_an_instance_of(ActiveStorage::Attached::Many)
    end
  end

  describe '#mark_best' do
    let!(:user) { create(:user) }
    let!(:question) { create(:question, author: user) }
    let!(:answer1) { create(:answer, best_answer: true, question: question) }
    let!(:answer2) { create(:answer, best_answer: false, question: question) }
    let!(:answer3) { create(:answer, best_answer: false, question: question) }

    before do
      answer2.mark_best
      answer1.reload
      answer2.reload
      answer3.reload
    end

    it 'should assign best answer' do
      expect(answer2).to be_best_answer
    end

    it 'should unset best answer from other answers' do
      expect(answer1).to_not be_best_answer
      expect(answer3).to_not be_best_answer
    end
  end
end

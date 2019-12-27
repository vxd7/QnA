require 'rails_helper'

RSpec.describe Question, type: :model do
  it_should_behave_like 'voteable', :question

  describe 'associations' do
    it { should have_many(:answers).dependent(:destroy) }
    it { should have_many(:links).dependent(:destroy) }
    it { should belong_to(:author).class_name(:User) }
    it { should have_one(:reward).dependent(:destroy) }
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
end

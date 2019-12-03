require 'rails_helper'

RSpec.describe User, type: :model do
  describe 'associations' do
    it { should have_many(:questions).dependent(:destroy) }
    it { should have_many(:answers).dependent(:destroy) }
  end

  it { should validate_presence_of :email }
  it { should validate_presence_of :password }

  describe '#author_of?' do
    let(:user) { create(:user) }
    let(:question) { create(:question) }
    let(:user_question) { create(:question, author: user) }

    it 'should correctly determine the authorship of the given resource' do
      expect(user).to be_author_of(user_question)
      expect(user).to_not be_author_of(question)
    end
  end
end

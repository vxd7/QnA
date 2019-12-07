require 'rails_helper'

RSpec.describe Answer, type: :model do
  describe 'associations' do
    it { should belong_to :question }
    it { should belong_to(:author).class_name(:User) }
  end

  describe 'attribute validations' do
    it { should validate_presence_of :body }

    describe 'best answer validation' do
      let!(:answer) { create(:answer) }
      it { should validate_uniqueness_of(:best_answer).scoped_to(:question_id)}
    end
  end
end

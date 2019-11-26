require 'rails_helper'

RSpec.describe Question, type: :model do
  describe 'associations' do
    it { should have_many :answers }
  end

  describe 'attribute validations' do
    context 'presence validations' do
      it { should validate_presence_of :title }
      it { should validate_presence_of :body }
    end
  end
end

require 'rails_helper'

RSpec.describe Vote, type: :model do
  describe 'associations' do
    it { should belong_to :voteable }
    it { should belong_to :user }
  end

  describe 'attribute validations' do
    it { should validate_presence_of :value }
    it do 
      should validate_numericality_of(:value)
        .is_less_than_or_equal_to(1)
        .is_greater_than_or_equal_to(-1)
        .only_integer 
    end
  end
end

require 'rails_helper'

RSpec.describe Reward, type: :model do
  describe 'associations' do
    it { should belong_to :question }
    it { should belong_to(:user).optional }
  end

  describe 'attribute validations' do
    it { should validate_presence_of :name }
    it { should validate_presence_of :image }
    it 'should have one attached image' do
      expect(Reward.new.image).to be_an_instance_of(ActiveStorage::Attached::One)
    end
  end
end

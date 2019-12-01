require 'rails_helper'

RSpec.describe Answer, type: :model do
  describe 'associations' do
    it { should belong_to :question }
    it { should belong_to(:author).class_name(:User) }
  end

  describe 'attribute validations' do
    it { should validate_presence_of :body }
    it { should validate_presence_of :author }
  end
end

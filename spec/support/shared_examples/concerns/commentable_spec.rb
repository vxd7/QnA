require 'rails_helper'
shared_examples_for 'commentable' do |resource_name|
  describe 'associations' do
    it { should have_many(:comments).dependent(:destroy) }
  end
end

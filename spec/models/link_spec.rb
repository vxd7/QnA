require 'rails_helper'

RSpec.describe Link, type: :model do
  it { should belong_to :linkable }
  it { should validate_presence_of :name }

  describe 'url validations' do
    let(:question) { create(:question) }
    let(:link) { question.links.new(name: 'Link name') }

    let(:valid_url1) { "http://google.com" }
    let(:valid_url2) { "https://google.com" }

    let(:invalid_url1) { "abacaba" }
    let(:invalid_url2) { ".ru" }

    it 'should allow valid urls' do
      link.url = valid_url1
      expect(link).to be_valid
    end

    it 'should allow valid urls' do
      link.url = valid_url2
      expect(link).to be_valid
    end

    it 'should not allow invalid urls' do
      link.url = invalid_url1
      expect(link).to_not be_valid
    end

    it 'should not allow invalid urls' do
      link.url = invalid_url2
      expect(link).to_not be_valid
    end
  end
end

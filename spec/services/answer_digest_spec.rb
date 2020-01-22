require 'rails_helper'

RSpec.describe Services::AnswerDigest do
  let!(:users) { create_list(:user, 3) }
  let(:question) { create(:question) }
  let!(:answer) { create(:answer, question: question) }

  before { users.each { |u| question.subscribe(u) } }

  it 'sends answer digest to all subscribed users' do
    # For subscribers
    users.each { |user| expect(AnswerDigestMailer).to receive(:digest).with(user, answer, question).and_call_original }

    # For author subscription exists by default
    expect(AnswerDigestMailer).to receive(:digest).with(question.author, answer, question).and_call_original
    subject.send_digest(answer)
  end
end

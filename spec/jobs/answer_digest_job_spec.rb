require 'rails_helper'

RSpec.describe AnswerDigestJob, type: :job do
  let(:service) { double('Services::AnswerDigest') }
  let(:answer) { create(:answer) }

  before do
    allow(Services::AnswerDigest).to receive(:new).and_return(service)
  end

  it 'calls Services::AnswerDigest#send_digest' do
    expect(service).to receive(:send_digest).with(answer)
    AnswerDigestJob.perform_now(answer)
  end
end

class AnswerDigestJob < ApplicationJob
  queue_as :default

  def perform(answer)
    Services::AnswerDigest.new.send_digest(answer)
  end
end

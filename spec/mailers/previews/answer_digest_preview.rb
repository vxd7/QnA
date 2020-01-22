# Preview all emails at http://localhost:3000/rails/mailers/answer_digest
class AnswerDigestPreview < ActionMailer::Preview

  # Preview this email at http://localhost:3000/rails/mailers/answer_digest/digest
  def digest
    AnswerDigestMailer.digest
  end

end

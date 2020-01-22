class AnswerDigestMailer < ApplicationMailer

  # Subject can be set in your I18n file at config/locales/en.yml
  # with the following lookup:
  #
  #   en.answer_digest_mailer.digest.subject
  #
  def digest(user, answer, question)
    @greeting = "Hi"
    @answer = answer
    @question = question

    mail to: user.email
  end
end

class Services::AnswerDigest
  def send_digest(answer)
    question = answer.question
    question.users_subscribed.each do |subscriber|
      AnswerDigestMailer.digest(subscriber, answer, question).deliver_later
    end
  end
end

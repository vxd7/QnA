class Services::AnswerDigest
  def send_digest(answer)
    question = answer.question
    question.users_subscribed.find_each(batch_size: 100) do |subscriber|
      AnswerDigestMailer.digest(subscriber, answer, question).deliver_later
    end
  end
end

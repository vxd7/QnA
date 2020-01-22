class DailyDigestMailer < ApplicationMailer
  def digest(user)
    @greeting = 'Hi'

    now = Time.now
    @target_questions = Question.where(created_at: (now - 24.hours)..now)
    mail to: user.email
  end
end

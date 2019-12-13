class Answer < ApplicationRecord
  belongs_to :question
  belongs_to :author, class_name: 'User', foreign_key: :user_id

  validates :body, presence: true
  # We want there to be only one answer marked as best for the given question
  # but multiple NOT BEST answers for the given question
  validates :best_answer, uniqueness: { scope: :question_id }, if: :best_answer?

  def mark_best
    # Remove best answer flag from previous best answer
    question.answers.find_by(best_answer: true)&.update_attribute(:best_answer, false)
    self.best_answer = true
    save
  end
end

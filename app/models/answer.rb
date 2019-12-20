class Answer < ApplicationRecord
  belongs_to :question
  belongs_to :author, class_name: 'User', foreign_key: :user_id
  has_many :links, dependent: :destroy, as: :linkable

  has_many_attached :files

  accepts_nested_attributes_for :links, reject_if: :all_blank, allow_destroy: true

  validates :body, presence: true
  # We want there to be only one answer marked as best for the given question
  # but multiple NOT BEST answers for the given question
  validates :best_answer, uniqueness: { scope: :question_id }, if: :best_answer?

  def mark_best
    transaction do
      # Remove best answer flag from previous best answer
      question.best_answer&.update!(best_answer: false)
      self.update!(best_answer: true)
      question.reward&.update!(user: author)
    end
  end
end

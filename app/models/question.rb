class Question < ApplicationRecord
  has_many :answers, dependent: :destroy
  belongs_to :author, class_name: 'User', foreign_key: :user_id

  has_many_attached :files

  validates :title, :body, presence: true

  def best_answer
    answers.find_by(best_answer: true)
  end
end

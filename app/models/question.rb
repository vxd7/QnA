class Question < ApplicationRecord
  include Voteable
  include Commentable

  has_many :answers, dependent: :destroy
  has_many :links, dependent: :destroy, as: :linkable
  has_one :reward, dependent: :destroy
  has_many :subscriptions, dependent: :destroy
  belongs_to :author, class_name: 'User', foreign_key: :user_id

  has_many_attached :files
  accepts_nested_attributes_for :links, reject_if: :all_blank, allow_destroy: true
  accepts_nested_attributes_for :reward, reject_if: :all_blank, allow_destroy: true

  validates :title, :body, presence: true

  after_create :calculate_reputation

  # Author of the question is auto subscribed to all new answers to that question
  after_create :autosubscribe

  def best_answer
    answers.find_by(best_answer: true)
  end

  def users_subscribed
    subscriptions.collect(&:user)
  end

  def subscribed?(user)
    users_subscribed.include?(user)
  end

  def subscribe(user)
    subscriptions.create(user: user) unless subscribed?(user)
  end

  def unsubscribe(user)
    subscriptions.find_by(user: user).delete if subscribed?(user)
  end

  private

  def calculate_reputation
    ReputationJob.perform_later(self)
  end

  def autosubscribe
    subscribe(author)
  end

end

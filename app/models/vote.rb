class Vote < ApplicationRecord
  belongs_to :voteable, polymorphic: true
  belongs_to :user

  validates :value, presence: true, numericality: { only_integer: true,  greater_than_or_equal_to: -1, less_than_or_equal_to: 1 }
end

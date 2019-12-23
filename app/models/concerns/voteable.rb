module Voteable
  extend ActiveSupport::Concern

  included do
    has_many :votes, dependent: :destroy, as: :voteable

    def upvote(user)
      votes.create(user: user, value: 1)
    end

    def downvote(user)
      votes.create(user: user, value: -1)
    end

    def rating
      return 0 unless has_votes?

      votes.sum(:value)
    end

    def has_votes?
      votes.any?
    end
  end
end

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

    def vote_by_user(user)
      votes.find_by(user: user)
    end

    def voteable_by?(user)
      # User can vote if they are NOT an author of the resource and haven't already voted
      !user.author_of?(self) && vote_by_user(user).nil?
    end
  end
end

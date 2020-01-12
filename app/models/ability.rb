# frozen_string_literal: true

class Ability
  include CanCan::Ability

  attr_reader :user

  def initialize(user)
    @user = user

    if user
      user.admin? ? admin_abilities : user_abilities
    else
      guest_abilities
    end
  end

  def guest_abilities
    can :read, :all
  end

  def admin_abilities
    can :manage, :all
  end

  def user_abilities
    guest_abilities
    can :create, [Question, Answer, Comment]
    can :update, [Question, Answer], user_id: user.id
    can :destroy, [Question, Answer], user_id: user.id

    # Can delete files only if we own the parent resource
    # which has these attached files
    can :destroy, ActiveStorage::Attachment do |file|
      parent_resource = file.record
      parent_resource.author.id == user.id
    end

    # Same goes for links too
    can :destroy, Link do |link|
      parent_resource = link.linkable
      parent_resource.author.id == user.id
    end

    can :upvote, [Question, Answer] do |resource|
      resource.voteable_by?(user)
    end

    can :downvote, [Question, Answer] do |resource|
      resource.voteable_by?(user)
    end

    can :cancel_vote, [Question, Answer] do |resource|
      resource.vote_by_user(user)
    end

    can :mark_best, Answer do |ans|
      user.author_of?(ans.question)
    end
  end
end

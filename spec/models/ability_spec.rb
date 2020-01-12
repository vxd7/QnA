require 'rails_helper'

describe Ability do
  subject(:ability) { Ability.new(user) }

  describe 'for guest' do
    let(:user) { nil }

    it { should be_able_to :read, Question }
    it { should be_able_to :read, Answer }
    it { should be_able_to :read, Comment }

    it { should_not be_able_to :manage, :all }
  end

  describe 'for admin' do
    let(:user) { create(:user, :admin) }

    it { should be_able_to :manage, :all }
  end

  describe 'for user' do
    let(:user) { create(:user) }
    let(:other) { create(:user) }

    it { should_not be_able_to :manage, :all }
    it { should be_able_to :read, :all }

    context 'question' do
      it { should be_able_to :create, Question }

      it { should be_able_to :update, create(:question, author: user) }
      it { should_not be_able_to :update, create(:question, author: other) }

      it { should be_able_to :destroy, create(:question, author: user) }
      it { should_not be_able_to :destroy, create(:question, author: other) }

      context 'files' do
        let(:question_attached_files_by_user) { create(:question, :with_files, author: user) }
        let(:question_attached_files_by_other) { create(:question, :with_files, author: other) }

        it { should be_able_to :destroy, question_attached_files_by_user.files.first }
        it { should_not be_able_to :destroy, question_attached_files_by_other.files.first }
      end

      context 'links' do
        let(:question_attached_links_by_user) { create(:question, :with_links, author: user) }
        let(:question_attached_links_by_other) { create(:question, :with_links, author: other) }

        it { should be_able_to :destroy, question_attached_links_by_user.links.first }
        it { should_not be_able_to :destroy, question_attached_links_by_other.links.first }
      end

      context 'votes' do
        let(:question_by_user) { create(:question, author: user) }
        let(:question_by_other) { create(:question, author: other) }

        context 'for own question' do
          # User should not be able to upvote their own question
          it { should_not be_able_to :upvote, question_by_user }
          it { should_not be_able_to :downvote, question_by_user }
        end

        context "for other's question" do
          # User should be able to upvote/downvote questions by other users
          it { should be_able_to :upvote, question_by_other }
          it { should be_able_to :downvote, question_by_other}
        end

        context 'if voted already' do
          let(:question_with_vote) { create(:question, author: other) }
          let!(:vote_for_question_with_vote) { create(:vote, voteable: question_with_vote, user: user) }

          # User should not be able to vote again
          it { should_not be_able_to :upvote, question_with_vote }
          it { should_not be_able_to :downvote, question_with_vote }
        end

        context 'cancel vote' do
          let(:question_without_votes) { create(:question, author: other) }

          # User should not be able to vote again
          it { should_not be_able_to :cancel_vote, question_without_votes}
        end
      end
    end

    context 'answer' do
      it { should be_able_to :create, Answer }

      it { should be_able_to :update, create(:answer, author: user) }
      it { should_not be_able_to :update, create(:answer, author: other) }

      it { should be_able_to :destroy, create(:question, author: user) }
      it { should_not be_able_to :destroy, create(:question, author: other) }

      context 'files' do
        let(:answer_attached_files_by_user) { create(:answer, :with_files, author: user) }
        let(:answer_attached_files_by_other) { create(:answer, :with_files, author: other) }

        it { should be_able_to :destroy, answer_attached_files_by_user.files.first }
        it { should_not be_able_to :destroy, answer_attached_files_by_other.files.first }
      end

      context 'links' do
        let(:answer_attached_links_by_user) { create(:answer, :with_link, author: user) }
        let(:answer_attached_links_by_other) { create(:answer, :with_link, author: other) }

        it { should be_able_to :destroy, answer_attached_links_by_user.links.first }
        it { should_not be_able_to :destroy, answer_attached_links_by_other.links.first }
      end

      context 'votes' do
        let(:answer_by_user) { create(:answer, author: user) }
        let(:answer_by_other) { create(:answer, author: other) }

        context 'for own answer' do
          # User should not be able to upvote their own answer
          it { should_not be_able_to :upvote, answer_by_user }
          it { should_not be_able_to :downvote, answer_by_user }
        end

        context "for other's answer" do
          # User should be able to upvote/downvote answers by other users
          it { should be_able_to :upvote, answer_by_other }
          it { should be_able_to :downvote, answer_by_other}
        end

        context 'if voted already' do
          let(:answer_with_vote) { create(:answer, author: other) }
          let!(:vote_for_answer_with_vote) { create(:vote, voteable: answer_with_vote, user: user) }

          # User should not be able to vote again
          it { should_not be_able_to :upvote, answer_with_vote }
          it { should_not be_able_to :downvote, answer_with_vote }
        end

        context 'cancel vote' do
          let(:answer_without_votes) { create(:answer, author: other) }

          # User should not be able to vote again
          it { should_not be_able_to :cancel_vote, answer_without_votes}
        end
      end

      context 'best answer' do
        let(:question_by_user) { create(:question, author: user) }
        let(:question_not_by_user) { create(:question) }

        let(:answer_by_other) { create(:answer, author: other, question: question_by_user) }
        let(:answer_for_question_not_by_user) { create(:answer, question: question_not_by_user) }

        # Can mark best for own question
        it { should be_able_to :mark_best, answer_by_other }

        # Cannot mark best for other question
        it { should_not be_able_to :mark_best, answer_for_question_not_by_user }
      end
    end

    context 'comments' do
      # We only create comments for now. Nothing else :(
      it { should be_able_to :create, Comment }
    end
  end
end

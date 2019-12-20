require 'rails_helper'

feature 'Author of the best answer can receive reward', %q{
  In order to boost my ego
  As an author of the best answer
  I'd like to be able to receive a reward
} do
  describe 'Authenticated user' do
    given(:best_answer_author) { create(:user) }

    given(:question) { create(:question, :with_reward) }
    given!(:best_answer) { create(:answer, :best_answer, question: question, author: best_answer_author) }

    background do
      sign_in(best_answer_author)
      best_answer.mark_best
      visit rewards_path
    end

    scenario 'receives the reward as an author of the best answer', js: true do
      expect(page).to have_content question.title
      expect(page).to have_content 'MyReward'
      expect(page).to have_selector 'img'
    end
  end
end


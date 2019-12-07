require 'rails_helper'

feature 'An author of a question can choose the best answer', %q{
  In order to mark a best answer for the question
  As an author of the question
  I'd like to be able to choose the best answer from avaliable answers
  and view this answer on top of the other answers
} do

  given!(:question_author) { create(:user) }
  given!(:question) { create(:question, author: question_author) }
  given!(:answers) { create_list(:answer, 5, :different, question: question) }
  describe 'Authenticated user' do
    background do
      sign_in(question_author)
      visit question_path question
    end

    describe 'as an author of the question', js: true do
      scenario 'selects best answer for the question' do
        within find(id: "answer-#{answers[3].id}") { click_on 'Mark best' }

        expect(page).to have_selector '.best-answer'
        within '.best-answer' do
          expect(page).to have_content answers[3].body
        end
      end

      scenario 'changes his mind and selects another answer as the best' do
        # Select answer#3 as the best
        within find(id: "answer-#{answers[3].id}") { click_on 'Mark best' }
        # Change best answer
        within find(id: "answer-#{answers[4].id}") { click_on 'Mark best' }

        expect(page).to have_selector '.best-answer'
        within '.best-answer' do
          expect(page).to have_content answers[4].body
          expect(page).to_not have_content answers[3].body
        end
      end
    end

    scenario "tries to select the best answer for the question they didnt't ask"
  end

  scenario 'Unauthenticated user tries to select best answer for the question'
end


require 'rails_helper'

feature 'User can add commentaries to the question or answer', %q{
  In order to ask additional questions or clarify some aspects
  As an authenticated user
  I would like to be able to add comments to questions and answers
} do
  given(:user) { create(:user) }
  given!(:question) { create(:question) }
  given!(:answer) { create(:answer, question: question) }

  describe 'Unauthenticated user', js: true do
    background { visit question_path question }

    scenario 'Tries to comment the question' do
      within find(id: "question-#{question.id}") do
        expect(page).to_not have_button 'Leave Comment'
      end
    end

    scenario 'Tries to comment an answer' do
      within find(id: "answer-#{answer.id}") do
        expect(page).to_not have_button 'Leave Comment'
      end
    end
  end

  describe 'Authenticated user' do
    background do 
      sign_in user
      visit question_path question
    end

    scenario 'comments question', js: true do
      within find(id: "question-#{question.id}") do
        fill_in 'Comment body', with: 'Test question comment text'
        click_on 'Leave Comment'
      end

      within find(id: "question-#{question.id}-comments") do
        expect(page).to have_content 'Test question comment text'
      end
    end

    scenario 'comments answer', js: true do
      within find(id: "answer-#{answer.id}") do
        fill_in 'Comment body', with: 'Test answer comment text'
        click_on 'Leave Comment'
      end

      within find(id: "answer-#{answer.id}-comments") do
        expect(page).to have_content 'Test answer comment text'
      end
    end
  end

  context 'multiple sessions' do
    scenario "comment appears on another user's page", js: true do
      Capybara.using_session('user') do
        sign_in(user)
        visit question_path(question)
      end

      Capybara.using_session('guest') do
        visit question_path(question)
      end

      Capybara.using_session('user') do
        within find(id: "question-#{question.id}") do
          fill_in 'Comment', with: 'Test question comment'
          click_on 'Leave Comment'
        end

        within find(id: "question-#{question.id}-comments") do
          expect(page).to have_content 'Test question comment text'
        end
      end

      Capybara.using_session('guest') do
        within find(id: "question-#{question.id}-comments") do
          expect(page).to have_content 'Test question comment'
        end
      end
    end
  end 
end

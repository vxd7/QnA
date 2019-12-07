require 'rails_helper'

feature 'User can edit their answer', %q{
  In order to correct mistakes
  As an author of an answer
  I'd like to be able to edit my answer
} do

  given!(:user) { create(:user) }
  given!(:question) { create(:question) }
  given!(:answer) { create(:answer, question: question, author: user) }

  scenario 'Unauithenticated user cannot edit an answer' do
    visit question_path question
    expect(page).to_not have_link 'Edit'
  end

  describe 'Authenticated user' do
    given!(:another_user) { create(:user) }
    given!(:another_users_answer) { create(:answer, question: question, author: another_user, body: 'Another user answer') }

    before do
      sign_in(user)
      visit question_path question
    end

    scenario 'edits their answer', js: true do
      within find(id: "answer-#{answer.id}") do
        click_on 'Edit'
        fill_in 'Your answer', with: 'edited answer'
        click_on 'Save'

        expect(page).to_not have_content answer.body
        expect(page).to have_content 'edited answer'
        expect(page).to_not have_selector 'textarea'
      end
    end

    scenario 'edits their answer with errors', js: true do
      click_on 'Edit'

      within '.answers' do
        fill_in 'Your answer', with: ''
        click_on 'Save'
        expect(page).to have_content answer.body
      end

      within '.answer-errors' do
        expect(page).to have_content "Body can't be blank"
      end
    end

    scenario "tries to edit someone else's answer", js: true do
      within '.answers' do
        within find(id: "answer-#{another_users_answer.id}") do
          expect(page).to_not have_link 'Edit'
        end
      end
    end

  end
end

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
    scenario 'edits their answer' do
      sign_in(user)
      visit question_path question

      click_on 'Edit'
      within '.body' do
        fill_in 'Your answer', with: 'edited answer'
        click_on 'Save'

        expect(page).to_not have_content answer_body
        expect(page).to have_content 'edited_answer'
        expect(page).to_not have_selector 'textarea'
      end

    end
    scenario 'edits their answer answer with errors'
    scenario "tries to edit someone else's answer"
  end
end

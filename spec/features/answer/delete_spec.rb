require 'rails_helper'

feature 'An author of the answer can delete their answer', %q{
  In order to remove the answer from the database
  As an authenticated user
  I'd like to be able to delete my answer
} do
  given!(:question) { create(:question) }
  given(:answers) { create_list(:answer, 2, :different, question: question) }

  describe 'Authenticated user' do
    before { sign_in(answers[0].author) }

    scenario 'deletes their answer', js: true do
      visit question_path question

      within find(id: "answer-#{answers[0].id}") do
        click_on 'Delete'
      end

      expect(page).to_not have_selector "#answer-#{answers[0].id}"
      expect(page).to_not have_content answers[0].body
    end

    scenario "tries to delete someone else's answer", js: true do
      visit question_path question

      within find(id: "answer-#{answers[1].id}") do
        expect(page).to_not have_link 'Delete'
      end
    end
  end

  scenario 'Unauthenticated user tries to delete an answer', js: true do
    visit question_path question
    expect(page).to_not have_link 'Delete'
  end
end

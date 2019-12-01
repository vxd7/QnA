require 'rails_helper'

feature 'An author of the question can delete their question', %q{
  In order to remove the question from the database
  As an authenticated user
  I'd like to be able to delete my question
} do
  background { visit questions_path }

  describe 'Authenticated user' do
    given(:questions) { create_list(:question, 2) }
    before { sign_in(questions[0].user) }

    scenario 'deletes their question' do
      visit question_path questions[0]
      click_on 'Delete'

      expect(page).to have_content 'Question was successfully deleted'
    end

    scenario "tries to delete someone else's question" do
      visit question_path questions[1]
      click_on 'Delete'

      expect(page).to have_content 'Cannot delete the question'
    end
  end

  scenario 'Unauthenticated user tries to delete a question'
end
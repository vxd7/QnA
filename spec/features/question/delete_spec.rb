require 'rails_helper'

feature 'An author of the question can delete their question', %q{
  In order to remove the question from the database
  As an authenticated user
  I'd like to be able to delete my question
} do
  background { visit questions_path }
  given(:questions) { create_list(:question, 2) }

  describe 'Authenticated user' do
    before { sign_in(questions[0].author) }

    scenario 'deletes their question' do
      visit question_path questions[0]
      click_on 'Delete'

      expect(page).to have_content 'Question was successfully deleted'
    end

    scenario "tries to delete someone else's question" do
      visit question_path questions[1]
      expect(page).to_not have_link 'Delete'
    end
  end

  scenario 'Unauthenticated user tries to delete a question' do
    visit question_path questions[0]
    expect(page).to_not have_link 'Delete'
  end
end

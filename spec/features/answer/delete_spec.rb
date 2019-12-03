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

    scenario 'deletes their answer' do
      visit answer_path answers[0]
      click_on 'Delete'

      expect(page).to have_content 'Answer was successfully deleted'
      expect(page).to_not have_content answers[0].body
    end

    scenario "tries to delete someone else's answer" do
      visit answer_path answers[1]
      expect(page).to_not have_link 'Delete'
    end
  end

  scenario 'Unauthenticated user tries to delete an answer' do
    visit answer_path answers[0]
    expect(page).to_not have_link 'Delete'
  end
end

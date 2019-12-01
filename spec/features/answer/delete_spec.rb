require 'rails_helper'

feature 'An author of the answer can delete their answer', %q{
  In order to remove the answer from the database
  As an authenticated user
  I'd like to be able to delete my answer
} do
  given(:answers) { create_list(:answer, 2) }

  describe 'Authenticated user' do
    before { sign_in(answers[0].author) }

    scenario 'deletes their answer' do
      visit answer_path answers[0]
      click_on 'Delete'

      expect(page).to have_content 'Answer was successfully deleted'
    end

    scenario "tries to delete someone else's answer" do
      visit answer_path answers[1]
      click_on 'Delete'

      expect(page).to have_content 'Cannot delete the answer'
    end
  end

  scenario 'Unauthenticated user tries to delete an answer' do
    visit answer_path answers[0]
    click_on 'Delete'

    expect(page).to have_content I18n.t('.devise.failure.unauthenticated')
  end
end

require 'rails_helper'

feature 'User can upvote/downvote the questions', %q{
  In order to rate the questions
  As an authenticated user
  I'd like to upvote/downvote the question
} do

  given(:user) { create(:user) }
  scenario 'Unauthenticated user tries to rate the question'

  describe 'Authenticated user', js: true do
    given(:question) { create(:question) }
    background do
      sign_in(user)
      visit question_page question
    end
    
    scenario 'Upvotes the question' do
      click_on 'Upvote'
      within '.rating' do
        expect(page).to have_content '1'
      end
      expect(page).to_not have_link 'Upvote'
      expect(page).to_not have_link 'Downvote'
      expect(page).to have_link 'Cancel vote'
    end

    scenario 'Downvotes the question' do
      click_on 'Downvote'
      within '.rating' do
        expect(page).to have_content '-1'
      end
      expect(page).to_not have_link 'Upvote'
      expect(page).to_not have_link 'Downvote'
      expect(page).to have_link 'Cancel vote'
    end
  end
end

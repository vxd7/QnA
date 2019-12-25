require 'rails_helper'

feature 'User can upvote/downvote the questions', %q{
  In order to rate the questions
  As an authenticated user
  I'd like to upvote/downvote the question
} do

  given(:user) { create(:user) }

  describe 'Unauthenticated user', js: true do
    given(:question) { create(:question) }
    background { visit question_path question }

    scenario 'Tries to rate the question' do
      within find(id: "question-#{question.id}") do
        expect(page).to_not have_link 'Upvote'
        expect(page).to_not have_link 'Downvote'
        expect(page).to_not have_link 'Cancel vote'
      end
    end
  end

  describe 'Authenticated user', js: true do
    given(:question) { create(:question) }
    background do
      sign_in(user)
      visit question_path question
    end
    
    scenario 'Upvotes the question' do
      click_on 'Upvote'
      within '.rating' do
        expect(page).to have_content '1'
      end
    end

    scenario 'Downvotes the question' do
      click_on 'Downvote'
      within '.rating' do
        expect(page).to have_content '-1'
      end
    end

    scenario 'Cancels vote' do
      click_on 'Upvote'
      click_on 'Cancel vote'
      within '.rating' do
        expect(page).to have_content '0'
      end
    end

    scenario 'Tries to upvote twice' do
      click_on 'Upvote'
      click_on 'Upvote'
      within '.rating' do
        expect(page).to have_content '1'
      end
    end

    scenario 'Tries to downvote twice' do
      click_on 'Downvote'
      click_on 'Downvote'
      within '.rating' do
        expect(page).to have_content '-1'
      end
    end
  end
end

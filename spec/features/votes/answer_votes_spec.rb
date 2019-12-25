require 'rails_helper'

feature 'User can upvote/downvote the answers', %q{
  In order to rate the answer
  As an authenticated user
  I'd like to upvote/downvote an answer
} do

  given(:user) { create(:user) }

  describe 'Unauthenticated user', js: true do
    given(:answer) { create(:answer) }
    background { visit question_path answer.question}

    scenario 'Tries to rate an answer' do
      within find(id: "answer-#{answer.id}") do
        expect(page).to_not have_link 'Upvote'
        expect(page).to_not have_link 'Downvote'
        expect(page).to_not have_link 'Cancel vote'
      end
    end
  end

  describe 'Authenticated user', js: true do
    given(:answer) { create(:answer) }
    background do
      sign_in(user)
      visit question_path answer.question
    end
    
    scenario 'Upvotes an answer' do
      within find(id: "answer-#{answer.id}") do
        click_on 'Upvote'
        within '.rating' do
          expect(page).to have_content '1'
        end
      end
    end

    scenario 'Downvotes an answer' do
      within find(id: "answer-#{answer.id}") do
        click_on 'Downvote'
        within '.rating' do
          expect(page).to have_content '-1'
        end
      end
    end

    scenario 'Cancels vote' do
      within find(id: "answer-#{answer.id}") do
        click_on 'Upvote'
        click_on 'Cancel vote'
        within '.rating' do
          expect(page).to have_content '0'
        end
      end
    end

    scenario 'Tries to upvote twice' do
      within find(id: "answer-#{answer.id}") do
        click_on 'Upvote'
        click_on 'Upvote'
        within '.rating' do
          expect(page).to have_content '1'
        end
      end
    end

    scenario 'Tries to downvote twice' do
      within find(id: "answer-#{answer.id}") do
        click_on 'Downvote'
        click_on 'Downvote'
        within '.rating' do
          expect(page).to have_content '-1'
        end
      end
    end
  end
end


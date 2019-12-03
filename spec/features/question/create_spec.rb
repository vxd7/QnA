require 'rails_helper'

feature 'User can create question', %q{
  In order to get answer from the community
  As an authenticated user
  I'd like to be able to ask the question
} do
  given(:user) { create(:user) }

  describe 'Authenticated user' do
    background do
      sign_in(user)
      visit questions_path
      click_on 'Ask question'
    end

    scenario 'asks a question' do
      fill_in 'Title', with: 'Test question'
      fill_in 'Body', with: 'Test question body'
      click_on 'Ask'

      expect(page).to have_content 'Your question was sucessfully created'
      expect(page).to have_content 'Test question'
      expect(page).to have_content 'Test question body'
    end

    scenario 'asks a question with errors' do
      click_on 'Ask'
      expect(page).to have_content "Title can't be blank"
    end
  end


  scenario 'Uneuthenticated user tries to ask a question' do
    visit questions_path
    click_on 'Ask question'

    expect(page).to have_content 'You need to sign in or sign up before continuing.'
  end
end

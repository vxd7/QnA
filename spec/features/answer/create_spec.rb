require 'rails_helper'

feature 'User can create an answer to the question', %q{
  In order to answer the selected question
  As an authenticated user
  I'd like to be able to create an answer to the question without leaving the selected question page
} do

  given(:user) { create(:user) }
  given(:question) { create(:question) }

  describe 'Authenticated user' do
    background do
      sign_in(user)
      visit question_path question
    end

    scenario 'answers a question', js: true do
      fill_in 'Body', with: 'Test answer body text'
      click_on 'Answer'

      within('.answers') do
        expect(page).to have_content 'Test answer body text'
      end
    end

    scenario 'answers a question incorrectly', js: true do
      click_on 'Answer'
      expect(page).to have_content "Body can't be blank"
    end

    scenario 'answers a question with attached files', js: true do
      fill_in 'Body', with: 'Test answer body text'
      attach_file 'Files', ["#{Rails.root}/spec/rails_helper.rb", "#{Rails.root}/spec/spec_helper.rb"]
      click_on 'Answer'
      
      within('.answers') do
        expect(page).to have_link 'rails_helper.rb'
        expect(page).to have_link 'spec_helper.rb'
      end
    end
  end

  scenario 'Unauthenticated user tries to answer a question', js: true do
    visit question_path question
    expect(page).to_not have_selector 'new-answer'
  end
end

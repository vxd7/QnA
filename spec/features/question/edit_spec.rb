require 'rails_helper'

feature 'User can edit their question', %q{
  In order to correct mistakes
  As an author of a question
  I'd like to be able to edit my question
} do

  given!(:user) { create(:user) }
  given!(:question) { create(:question, author: user) }

  scenario 'Unauthenticated user cannot edit a question' do
    visit questions_path question
    within find(id: "question-#{question.id}") do
      expect(page).to_not have_link 'Edit'
    end
  end

  describe 'Authenticated user' do
    given!(:another_user) { create(:user) }
    given!(:another_users_question) { create(:question, author: another_user, body: 'Another user question') }

    before do
      sign_in(user)
    end

    scenario 'edits their question', js: true do
      visit question_path question
      within find(id: "question-#{question.id}") do
        click_on 'Edit'
        fill_in 'Title', with: 'New question title'
        fill_in 'Body', with: 'New questino body'
        click_on 'Save'

        expect(page).to_not have_content question.title
        expect(page).to_not have_content question.body
        expect(page).to have_content 'New question title'
        expect(page).to have_content 'New question body'
        expect(page).to_not have_selector 'textarea'
      end
    end

    scenario 'edits their question with errors'
    scenario "tries to edit someone else's question"
  end
end

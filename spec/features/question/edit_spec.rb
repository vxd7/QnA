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

    given!(:question_with_files) { create(:question, :with_files, author: user) }
    given!(:another_users_question_with_files) { create(:question, :with_files, author: another_user) }

    before do
      sign_in(user)
    end

    scenario 'edits their question', js: true do
      visit question_path question
      within find(id: "question-#{question.id}") do
        click_on 'Edit'
        fill_in 'Title', with: 'New question title'
        fill_in 'Body', with: 'New question body'
        click_on 'Save'

        expect(page).to_not have_content question.title
        expect(page).to_not have_content question.body
        expect(page).to have_content 'New question title'
        expect(page).to have_content 'New question body'
        expect(page).to_not have_selector 'textarea'
      end
    end

    scenario 'attaches files while editing the question', js: true do
      visit question_path question
      within find(id: "question-#{question.id}") do
        click_on 'Edit'
        attach_file 'File', ["#{Rails.root}/spec/rails_helper.rb", "#{Rails.root}/spec/spec_helper.rb"]
        click_on 'Save'

        expect(page).to have_link 'rails_helper.rb'
        expect(page).to have_link 'spec_helper.rb'
      end
    end

    # scenario 'attaches files to the question with existing files', js: true do
    #   visit question_path question_with_files
    #   within find(id: "question-#{question_with_files.id}") do
    #     click_on 'Edit'
    #     attach_file 'File', ["#{Rails.root}/spec/models/answer_spec.rb", "#{Rails.root}/spec/models/question_spec.rb"]
    #     click_on 'Save'

    #     expect(page).to have_link 'rails_helper.rb'
    #     expect(page).to have_link 'spec_helper.rb'
    #     expect(page).to have_link 'answer_spec.rb'
    #     expect(page).to have_link 'question_spec.rb'
    #   end
    # end

    scenario 'deletes file while editing the question', js: true do
      visit question_path question_with_files
      within find(id: "question-#{question_with_files.id}-file-#{question_with_files.files.first.id}") do
        click_on 'Delete'
      end
      expect(page).to_not have_content question_with_files.files.first.filename.to_s
    end

    scenario "tries to delete someone else's file", js: true do
      visit question_path another_users_question_with_files 
      within find(id: "question-#{another_users_question_with_files.id}-file-#{another_users_question_with_files.files.first.id}") do
        expect(page).to_not have_link 'Delete'
      end
    end

    scenario 'edits their question with errors', js: true do
      visit question_path question
      within find(id: "question-#{question.id}") do
        click_on 'Edit'
        fill_in 'Body', with: ''
        click_on 'Save'

        expect(page).to have_content question.title
        expect(page).to have_content question.body
      end

      within '.question-errors' do
        expect(page).to have_content "Body can't be blank"
      end
    end

    scenario "tries to edit someone else's question", js: true do
      visit question_path another_users_question
      within find(id: "question-#{another_users_question.id}") do
        expect(page).to_not have_link 'Edit'
      end
    end
  end
end

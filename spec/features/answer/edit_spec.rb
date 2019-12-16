require 'rails_helper'

feature 'User can edit their answer', %q{
  In order to correct mistakes
  As an author of an answer
  I'd like to be able to edit my answer
} do

  given!(:user) { create(:user) }
  given!(:question) { create(:question) }
  given!(:answer) { create(:answer, question: question, author: user) }

  scenario 'Unauithenticated user cannot edit an answer' do
    visit question_path question
    expect(page).to_not have_link 'Edit'
  end

  describe 'Authenticated user' do
    given!(:another_user) { create(:user) }
    given!(:another_users_answer) { create(:answer, question: question, author: another_user, body: 'Another user answer') }

    given!(:answer_with_attachments) { create(:answer, :with_files, question: question, author: user) }
    given!(:another_users_answer_with_attachments) { create(:answer, :with_files, question: question, author: another_user) }

    before do
      sign_in(user)
      visit question_path question
    end

    scenario 'edits their answer', js: true do
      within find(id: "answer-#{answer.id}") do
        click_on 'Edit'
        fill_in 'Your answer', with: 'edited answer'
        click_on 'Save'

        expect(page).to_not have_content answer.body
        expect(page).to have_content 'edited answer'
        expect(page).to_not have_selector 'textarea'
      end
    end

    scenario 'attaches files while editing the answer', js: true do
      within find(id: "answer-#{answer.id}") do
        click_on 'Edit'
        fill_in 'Your answer', with: 'edited answer'
        attach_file 'File', ["#{Rails.root}/spec/rails_helper.rb", "#{Rails.root}/spec/spec_helper.rb"]
        click_on 'Save'

        expect(page).to have_link 'rails_helper.rb'
        expect(page).to have_link 'spec_helper.rb'
      end
    end

    scenario 'attaches files to the answer with existing files', js: true do
      within find(id: "answer-#{answer_with_attachments.id}") do
        click_on 'Edit'
        attach_file 'File', ["#{Rails.root}/spec/models/answer_spec.rb", "#{Rails.root}/spec/models/question_spec.rb"]
        click_on 'Save'

        expect(page).to have_link 'rails_helper.rb'
        expect(page).to have_link 'spec_helper.rb'
        expect(page).to have_link 'answer_spec.rb'
        expect(page).to have_link 'question_spec.rb'
      end
    end

    scenario 'deletes file while editing the answer', js: true do
      within find(id: "answer-#{answer_with_attachments.id}-file-#{answer_with_attachments.files.first.id}") do
        click_on 'Delete'
      end

      within find(id: "answer-#{answer_with_attachments.id}-files") do
        expect(page).to_not have_content answer_with_attachments.files.first.filename.to_s
      end
    end

    scenario "tries to delete someone else's file", js: true do
      within find(id: "answer-#{another_users_answer_with_attachments.id}-file-#{another_users_answer_with_attachments.files.first.id}") do
        expect(page).to_not have_link 'Delete'
      end
    end

    scenario 'edits their answer with errors', js: true do
      within find(id: "answer-#{answer.id}") do
        click_on 'Edit'
      end

      within '.answers' do
        fill_in 'Your answer', with: ''
        click_on 'Save'
        expect(page).to have_content answer.body
      end

      within '.answer-errors' do
        expect(page).to have_content "Body can't be blank"
      end
    end

    scenario "tries to edit someone else's answer", js: true do
      within '.answers' do
        within find(id: "answer-#{another_users_answer.id}") do
          expect(page).to_not have_link 'Edit'
        end
      end
    end

  end
end

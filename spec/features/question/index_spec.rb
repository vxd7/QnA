require 'rails_helper'

feature 'User can view the list of all questions', %q{
  In order to familiarize myself with the questions and answers
  As an authenticated or unauthenticated user
  I'd like to be able to view list of all of the questions
} do

  given(:user) { create(:user) }

  scenario 'Authenticated user views list of all questions' do
    sign_in(user)
    visit questions_path

    expect(page).to have_content 'All questions'
  end

  scenario 'Unauthenticated user views list of all questions' do
    visit questions_path

    expect(page).to have_content 'All questions'
  end
end

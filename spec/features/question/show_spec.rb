require 'rails_helper'

feature 'User can view selected question', %q{
  In order to view the slected question and all answers to this question
  As an authenticated or unauthenticated user
  I'd like to be able to visit the question page and view question with answers
} do
  given(:user) { create(:user) }
  given!(:question) { create(:question) }
  given!(:answers) { create_list(:answer, 3, :different, question: question) }

  scenario 'Authenticated user visits question page and views question and answers' do
    sign_in(user)
    visit question_path question

    expect(page).to have_content question.title
    expect(page).to have_content question.body

    expect(page).to have_content 'Answers to this question'
    answers.each { |ans| expect(page).to have_content ans.body }
  end

  scenario 'Unauthenticated user visits question page and views question and answers' do
    visit question_path question

    expect(page).to have_content question.title
    expect(page).to have_content question.body

    expect(page).to have_content 'Answers to this question'
    answers.each { |ans| expect(page).to have_content ans.body }
  end
end

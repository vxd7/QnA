require 'rails_helper'

feature 'User can unsubscribe from the question', %q{
  In order to stop receiving notifications to the new answers
  As an authenticated user
  I'd like to be able to unsubscribe from the question
} do

  let!(:question) { create(:question) }
  scenario 'Unauthenticated user' do
    visit question_path(question)

    expect(page).to_not have_link('Unsubscribe')
  end

  context 'Authenticated user' do
    let!(:user) { create(:user) }
    before { sign_in(user) }

    context 'with an existing subscription to this question', js: true do
      before { question.subscribe(user) }

      scenario 'tries to unsubscribe' do
        visit question_path(question)
        click_on 'Unsubscribe'
        expect(page).to have_link('Subscribe')
      end
    end

    scenario 'withiut subscription to this question subscribes', js: true do
      visit question_path(question)
      expect(page).to_not have_link 'Unsubscribe'
    end
  end
end 

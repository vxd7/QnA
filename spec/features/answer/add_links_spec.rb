require 'rails_helper'

feature 'User can add links to answer', %q{
  In order to provide additional information to the answer
  As an answer's author
  I'd like to be able to add links to the answer
} do
  given(:user) { create(:user) }
  given(:question) { create(:question, author: user) }
  given(:gist_url) { 'https://gist.github.com/vxd7/129c38035a31a773775b45e4987e52af' }

  scenario 'User adds link when answering the question', js: true do
    sign_in(user)
    visit question_path(question)

    fill_in 'Body', with: 'My answer'
    fill_in 'Link name', with: 'My gist'
    fill_in 'Url', with: gist_url

    click_on 'Answer'

    within '.answers' do
      expect(page).to have_link 'My gist', href: gist_url
    end
  end
end


require 'rails_helper'

feature 'User can add links to answer', %q{
  In order to provide additional information to the answer
  As an answer's author
  I'd like to be able to add links to the answer
} do
  given(:user) { create(:user) }
  given(:question) { create(:question, author: user) }
  given(:gist_url) { 'https://gist.github.com/vxd7/129c38035a31a773775b45e4987e52af' }
  given(:test_url) { 'http://test.com' }

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

  scenario 'User tries to add incorrect link when answering the question', js: true do
    sign_in(user)
    visit question_path(question)

    fill_in 'Body', with: 'My answer'
    fill_in 'Link name', with: 'My gist'
    fill_in 'Url', with: 'incorrect link'

    click_on 'Answer'

    expect(page).to have_text 'url is invalid'
  end

  scenario 'User adds multiple links when answering the question', js: true do
    sign_in(user)
    visit question_path(question) 

    fill_in 'Body', with: 'My answer'

    fill_in 'Link name', with: 'My gist'
    fill_in 'Url', with: gist_url

    click_on 'Add link'

    within all('.nested-fields').last do
      fill_in 'Link name', with: 'Other link'
      fill_in 'Url', with: test_url 
    end

    click_on 'Answer'

    within '.answers' do
      expect(page).to have_link 'My gist', href: gist_url
      expect(page).to have_link 'Other link', href: test_url
    end
  end
end


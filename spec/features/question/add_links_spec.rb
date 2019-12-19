require 'rails_helper'

feature 'User can add links to question', %q{
  In order to provide additional information to the question
  As a question's author
  I'd like to be able to add links to the question
} do
  given(:user) { create(:user) }
  given(:gist_url) { 'https://gist.github.com/vxd7/129c38035a31a773775b45e4987e52af' }
  given(:test_url) { 'http://test.com' }

  scenario 'User adds link when asking the question', js: true do
    sign_in(user)
    visit new_question_path

    fill_in 'Title', with: 'Test question'
    fill_in 'Body', with: 'Test question body'

    fill_in 'Link name', with: 'My gist'
    fill_in 'Url', with: gist_url

    click_on 'Ask'
    expect(page).to have_link 'My gist', href: gist_url
  end

  scenario 'User tries to add incorrect link while asking the question' do
    sign_in(user)
    visit new_question_path

    fill_in 'Title', with: 'Test question'
    fill_in 'Body', with: 'Test question body'

    fill_in 'Link name', with: 'My gist'
    fill_in 'Url', with: 'incorrect_url'

    click_on 'Ask'
    expect(page).to have_text 'url is invalid'
  end

  scenario 'User adds multiple links when asking the question', js: true do
    sign_in(user)
    visit new_question_path

    fill_in 'Title', with: 'Test question'
    fill_in 'Body', with: 'Test question body'


    fill_in 'Link name', with: 'My gist'
    fill_in 'Url', with: gist_url

    click_on 'Add link'

    within all('.nested-fields').last do
      fill_in 'Link name', with: 'Other link'
      fill_in 'Url', with: test_url 
    end

    click_on 'Ask'
    expect(page).to have_link 'My gist', href: gist_url
    expect(page).to have_link 'Other link', href: test_url
  end
end

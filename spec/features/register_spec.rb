require 'rails_helper'

feature 'Person can register in the system', %q{
  In order to start working with the site
  As an unregistered user
  I'd like to register my user account
} do
  background do
    visit root_path
    click_link 'Register an account'
  end

  scenario 'New user tries to create a valid user account' do
    fill_in 'Email', with: 'test@test.com'
    fill_in 'Password', with: '12345678'
    fill_in 'Password confirmation', with: '12345678'
    click_button 'Sign up'

    expect(page).to have_content I18n.t('.devise.registrations.signed_up')
  end

  scenario 'New user tries to create an invalid user account' do
    click_button 'Sign up'
    expect(page).to have_content "Email can't be blank"
  end
end

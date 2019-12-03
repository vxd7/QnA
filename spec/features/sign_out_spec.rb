require 'rails_helper'

feature 'User can sign out', %q{
  In order to finish working with the site
  As an authenticated user
  I'd like to sign out
} do
  given(:user) { create(:user) }

  scenario 'Authenticated user signs out' do # destroy_user_session_path
    sign_in(user)
    visit questions_path
    click_on 'Log out'

    expect(page).to have_content I18n.t('.devise.sessions.signed_out')
    expect(page).to have_content 'Log in'
  end
end

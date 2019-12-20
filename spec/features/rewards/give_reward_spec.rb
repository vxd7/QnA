require 'rails_helper'

feature 'Author of the question can reward the user who wrote the best answer', %q{
  In order to reward the author of the best question
  As an author of the question
  I'd like to be able to define the rewards when creating the question
} do
  describe 'Authenticated user' do
    given(:user) { create(:user) }
    background { sign_in(user) }

    scenario 'creates the reward when asking the question', js: true do
      visit new_question_path
      expect(page).to have_field 'Reward name'
      expect(page).to have_field 'Reward image'
    end
  end
end

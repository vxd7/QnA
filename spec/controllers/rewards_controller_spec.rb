require 'rails_helper'

RSpec.describe RewardsController, type: :controller do
  let(:user) { create(:user) }
  let(:question1) { create(:question, :with_reward) }
  let(:question2) { create(:question, :with_reward) }

  describe 'GET #index' do
    before do
      login(user)
      get :index
    end

    it 'populates an array of all rewards' do
      expect(assigns(:rewards)).to match_array([question1.reward, question2.reward])
    end

    it 'renders index view' do
      expect(response).to render_template :index
    end
  end
end

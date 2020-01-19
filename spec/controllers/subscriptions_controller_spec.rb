require 'rails_helper'

RSpec.describe SubscriptionsController, type: :controller do
  let!(:user) { create(:user) }
  describe 'Unauthenticated' do
    let!(:question) { create(:question) }
    it 'does not allow subscriptions for guests' do
      post :create, params: { question_id: question }, format: :js
      expect(response).to_not be_successful
    end
  end

  describe 'Authenticated' do
    let!(:question) { create(:question) }
    before do
      login(user) 
      post :create, params: { question_id: question }, format: :js 
    end

    describe 'POST #create' do
      it 'assigns question to @question' do
        expect(assigns(:question)).to eq question
      end

      it 'creates subscriptions if user is not already subscribed' do
        question.reload
        expect(question.users_subscribed).to include user
      end

      it 'renders the create view' do
        expect(response).to render_template :create
      end
    end

    describe 'DELETE #destroy' do
      before do
        question.subscribe(user)
      end

      it 'deletes subscription if user has subscribed to the question' do
        expect do
          delete :destroy, params: { id: question.subscriptions.first, question_id: question }, format: :js
        end.to change(question.subscriptions, :count).by(-1)
      end

      it 'renders the destroy view' do
        delete :destroy, params: { id: question.subscriptions.first, question_id: question }, format: :js
        expect(response).to render_template :destroy
      end
    end
  end
end


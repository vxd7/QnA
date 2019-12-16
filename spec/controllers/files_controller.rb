require 'rails_helper'

RSpec.describe FilesController, type: :controller do
  let(:user) { create(:user) }

  describe 'DELETE #destroy' do
    before { login(user) }

    context 'of the owned file' do
      let!(:question) { create(:question, :with_files, author: user) }
      let!(:answer) { create(:answer, :with_files, author: user) }

      it 'deletes the file' do
        expect { delete :destroy, params: { id: question.files.first }, format: :js }.to change(question.files, :count).by(-1)
        expect { delete :destroy, params: { id: answer.files.first }, format: :js }.to change(answer.files, :count).by(-1)
      end

      it 'renders destroy template' do
        delete :destroy, params: { id: question.files.first }, format: :js
        expect(response).to render_template :destroy
      end
    end

    context 'of the not owned file' do
      let!(:question) { create(:question, :with_files) }
      let!(:answer) { create(:answer, :with_files) }

      it 'does not delete the file' do
        expect { delete :destroy, params: { id: question.files.first }, format: :js }.to_not change(question.files, :count)
        expect { delete :destroy, params: { id: answer.files.first }, format: :js }.to_not change(answer.files, :count)
      end

      it 'renders destroy template' do
        delete :destroy, params: { id: question.files.first }, format: :js
        expect(response).to render_template :destroy
      end
    end
  end

end

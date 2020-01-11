require 'rails_helper'

RSpec.describe AnswersController, type: :controller do
  it_should_behave_like 'voted', :answer

  let(:user) { create(:user) }
  let(:question) { create(:question) }

  describe 'GET #new' do
    # Answer is a dependent model of Question model
    # so to create it we need question id
    before { login(user) }
    before { get :new, params: { question_id: question } }

    it 'should assign question to @question' do
      expect(assigns(:question)).to eq question
    end

    it 'should assign a new Answer to @answer' do
      expect(assigns(:answer)).to be_a_new(Answer)
    end

    it 'should render correct view' do
      expect(response).to render_template :new
    end
  end

  describe 'POST #create' do
    before { login(user) }

    context 'with valid attributes' do
      it 'assigns correct question (for this answer) to @question' do
        post :create, params: { answer: attributes_for(:answer), question_id: question }, format: :js
        expect(assigns(:question)).to eq question
      end

      it 'assigns correct author for the answer' do
        post :create, params: { answer: attributes_for(:answer), question_id: question }, format: :js
        expect(user).to be_author_of(assigns(:answer))
      end

      it 'saves new answer in the DB' do
        expect { post :create, params: { answer: attributes_for(:answer), question_id: question }, format: :js}.to change(question.answers, :count).by(1)
      end

      it 'renders create template' do
        post :create, params: { answer: attributes_for(:answer), question_id: question, format: :js }
        expect(response).to render_template :create
      end
    end

    context 'with invalid attributes' do
      it 'does not save the answer in the DB' do
        expect { post :create, params: { answer: attributes_for(:answer, :invalid), question_id: question }, format: :js }.to_not change(question.answers, :count)
      end

      it 'renders create template' do
        post :create, params: { answer: attributes_for(:answer, :invalid), question_id: question, format: :js }
        expect(response).to render_template :create
      end
    end
  end

  describe 'GET #show' do
    let(:answer) { create(:answer, question: question) }

    before { get :show, params: { id: answer } }

    it 'assigns the requested answer to @answer' do
      expect(assigns(:answer)).to eq answer
    end

    it 'renders show view' do
      expect(response).to render_template :show
    end
  end

  describe 'DELETE #destroy' do
    before { login(user) }
    let!(:answer) { create(:answer) }

    context 'of the answer by the author of the answer' do
      before { login(answer.author) }

      it 'deletes the answer' do
        expect { delete :destroy, params: { id: answer }, format: :js }.to change(Answer, :count).by(-1)
      end
    end

    context 'of the answer not owned by the current user' do
      it 'forbids the deletion of the answer not owned by the user' do
        expect { delete :destroy, params: { id: answer }, format: :js}.to_not change(Answer, :count)
      end
    end

    it "renders destroy view" do
      delete :destroy, params: { id: answer }, format: :js
      expect(response).to render_template :destroy
    end
  end

  describe 'PATCH #update' do
    let!(:answer) { create(:answer, question: question) }
    before { login(answer.author) }

    context 'with valid attributes' do
      let!(:file1) { Rack::Test::UploadedFile.new("#{Rails.root}/spec/rails_helper.rb") }
      let!(:file2) { Rack::Test::UploadedFile.new("#{Rails.root}/spec/spec_helper.rb") }

      it 'changes the answer attributes' do
        patch :update, params: { id: answer, answer: { body: 'new body' } }, format: :js
        answer.reload
        expect(answer.body).to eq 'new body'
      end

      it 'renders update view' do
        patch :update, params: { id: answer, answer: { body: 'new body' } }, format: :js
        expect(response).to render_template :update
      end

      it 'attaches files' do
        patch :update, params: { id: answer, answer: { files: [file1, file2] } }, format: :js
        answer.reload
        expect(answer.files.count).to eq 2
      end
    end

    context 'with invalid attributes' do
      it 'does not change answer attributes' do
        expect do
          patch :update, params: { id: answer, answer: attributes_for(:answer, :invalid) }, format: :js
        end.to_not change(answer, :body)
      end

      it 'renders update view' do
        patch :update, params: { id: answer, answer: attributes_for(:answer, :invalid) }, format: :js
        expect(response).to render_template :update
      end
    end
  end

  describe 'PATCH #mark_best' do
    let!(:question) { create(:question, author: user) }
    let!(:answer) { create(:answer, question: question) }
    let!(:another_answer) { create(:answer) }

    before { login(user) }

    context 'of the answer by the author of the question' do
      it 'marks selected answer as the best' do
        patch :mark_best, params: { id: answer }, format: :js
        answer.reload
        expect(answer).to be_best_answer
      end

      it 'renders mark_best view' do
        patch :mark_best, params: { id: answer }, format: :js
        expect(response).to render_template :mark_best
      end
    end

    context 'of the answer by another user' do
      it 'does not mark the answer as the best' do
        patch :mark_best, params: { id: another_answer }, format: :js
        expect(another_answer).to_not be_best_answer
      end

      it 'renders mark_best view' do
        patch :mark_best, params: { id: another_answer }, format: :js
        expect(response).to render_template :mark_best
      end
    end
  end
end

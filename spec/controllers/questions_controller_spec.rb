require 'rails_helper'

RSpec.describe QuestionsController, type: :controller do
  it_should_behave_like 'voted', :question

  let(:question) { create(:question) }
  let(:user) { create(:user) }

  describe 'GET #index' do
    let(:questions) { create_list(:question, 3) }

    before { get :index }

    it 'populates an array of all questions' do
      expect(assigns(:questions)).to match_array(questions)
    end

    it 'renders index view' do
      expect(response).to render_template :index
    end
  end

  describe 'GET #show' do
    before { get :show, params: { id: question } }

    it 'assigns the requested question to @question' do
      expect(assigns(:question)).to eq question
    end

    it 'assigns the new answer for question' do
      expect(assigns(:answer)).to be_a_new(Answer)
    end

    it 'assigns a new link for an answer' do
      expect(assigns(:answer).links.first).to be_a_new(Link)
    end

    it 'renders show view' do
      expect(response).to render_template :show
    end
  end

  describe 'GET #new' do
    before { login(user) }
    before { get :new }

    it 'assigns a new Question to @question' do
      expect(assigns(:question)).to be_a_new(Question)
    end

    it 'assigns a new Question to @question' do
      expect(assigns(:question).links.first).to be_a_new(Link)
    end

    it 'renders new view' do
      expect(response).to render_template :new
    end
  end

  # Edit is not needed. We do AJAX update
  #
  # describe 'GET #edit' do
  #   before { login(user) }
  #   before { get :edit, params: { id: question } }

  #   it 'assigns the requested question to @question' do
  #     expect(assigns(:question)).to eq question
  #   end

  #   it 'renders edit view' do
  #     expect(response).to render_template :edit
  #   end
  # end

  describe 'POST #create' do
    before { login(user) }

    context 'with valid attributes' do
      it 'saves new question in the database' do
        expect { post :create, params: { question: attributes_for(:question) } }.to change(Question, :count).by(1)
      end

      it 'assigns correct author for the question' do
        post :create, params: { question: attributes_for(:question) }
        expect(user).to be_author_of(assigns(:question))
      end

      it 'redirects to show view' do
        post :create, params: { question: attributes_for(:question) }
        expect(response).to redirect_to assigns(:question)
      end
    end
    context 'with invalid attributes' do
      it 'does not save the question' do
        expect { post :create, params: { question: attributes_for(:question, :invalid) } }.to_not change(Question, :count)
      end

      it 're-renders new view' do
        post :create, params: { question: attributes_for(:question, :invalid) }
        expect(response).to render_template :new
      end
    end
  end

  describe 'PATCH #update' do

    context 'by the author of the question' do
      before { login(question.author) }

      context 'with valid attributes' do
        let!(:file1) { Rack::Test::UploadedFile.new("#{Rails.root}/spec/rails_helper.rb") }
        let!(:file2) { Rack::Test::UploadedFile.new("#{Rails.root}/spec/spec_helper.rb") }

        it 'assigns the requested question to @question' do
          patch :update, params: { id: question, question: attributes_for(:question) }, format: :js
          expect(assigns(:question)).to eq question
        end

        it 'changes question attributes' do
          patch :update, params: { id: question, question: { title: 'new title', body: 'new body' } }, format: :js
          question.reload

          expect(question.title).to eq 'new title'
          expect(question.body).to eq 'new body'
        end

        it 'renders update view' do
          patch :update, params: { id: question, question: attributes_for(:question) }, format: :js
          expect(response).to render_template :update
        end

        it 'attaches files' do
          patch :update, params: { id: question, question: { files: [file1, file2] } }, format: :js
          question.reload
          expect(question.files.count).to eq 2
        end
      end

      context 'with invalid attributes' do
        before { patch :update, params: { id: question, question: attributes_for(:question, :invalid) }, format: :js }

        it 'does not change the question' do
          question.reload

          expect(question.title).to eq 'QuestionTitle'
          expect(question.body).to eq 'QuestionBody'
        end

        it 'renders update view' do
          expect(response).to render_template :update
        end
      end
    end

    context 'by someone else' do
      before { login(user) }
      before { patch :update, params: { id: question, question: attributes_for(:question) }, format: :js }

      it 'does not change the question attributes' do
        question.reload

        expect(question.title).to eq 'QuestionTitle'
        expect(question.body).to eq 'QuestionBody'
      end

      it 'responds with 403' do
        expect(response.status).to eq 403
      end
    end

  end

  describe 'DELETE #destroy' do
    before { login(user) }
    let!(:question) { create(:question) }

    context 'of the question by the author of the question' do
      before { login(question.author) }

      it 'deletes the question' do
        expect { delete :destroy, params: { id: question } }.to change(Question, :count).by(-1)
      end
    end

    context 'of the question not owned by the current user' do
      it 'forbids the deletion of the question not owned by the user' do
        expect { delete :destroy, params: { id: question } }.to_not change(Question, :count)
      end
    end

    it 'redirects to root path' do
      delete :destroy, params: { id: question }
      expect(response).to redirect_to root_path
    end
  end
end

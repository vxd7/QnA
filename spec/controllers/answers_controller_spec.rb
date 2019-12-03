require 'rails_helper'

RSpec.describe AnswersController, type: :controller do
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
        post :create, params: { answer: attributes_for(:answer), question_id: question }
        expect(assigns(:question)).to eq question
      end

      it 'assigns correct author for the answer' do
        post :create, params: { answer: attributes_for(:answer), question_id: question }
        expect(user).to be_author_of(assigns(:answer))
      end

      it 'saves new answer in the DB' do
        expect { post :create, params: { answer: attributes_for(:answer), question_id: question } }.to change(question.answers, :count).by(1)
      end

      it 'redirects to show view' do
        post :create, params: { answer: attributes_for(:answer), question_id: question } 
        expect(response).to redirect_to assigns(:answer)
      end
    end

    context 'with invalid attributes' do
      it 'does not save the answer in the DB' do
        expect { post :create, params: { answer: attributes_for(:answer, :invalid), question_id: question } }.to_not change(question.answers, :count)
      end

      it 're-renders new view' do
        post :create, params: { answer: attributes_for(:answer, :invalid), question_id: question } 
        expect(response).to render_template :new
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
        expect { delete :destroy, params: { id: answer } }.to change(Answer, :count).by(-1)
      end
    end

    context 'of the answer not owned by the current user' do
      it 'forbids the deletion of the answer not owned by the user' do
        expect { delete :destroy, params: { id: answer } }.to_not change(Answer, :count)
      end
    end

    it "redirects to answer's question page" do
      delete :destroy, params: { id: answer }
      expect(response).to redirect_to question_path answer.question
    end
  end
end

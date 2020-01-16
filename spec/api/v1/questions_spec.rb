require 'rails_helper'

describe 'Questions API', type: :request do
  let(:headers) { { "CONTENT_TYPE" => "application/json",
                    "ACCEPT" => 'application/json' } }

  describe 'GET /api/v1/questions' do
    it_behaves_like 'API Authorizable' do
      let(:api_path) { '/api/v1/questions' }
      let(:method) { :get }
    end

    context 'authorized' do
      let(:access_token) { create(:access_token) }
      let!(:questions) { create_list(:question, 2) }
      let(:question) { questions.first }
      let(:question_response) { json['questions'].first }
      let!(:answers) { create_list(:answer, 3, question: question) }

      before { get '/api/v1/questions', params: { access_token: access_token.token }, headers: headers }
      
      it 'returns 200 status' do
        expect(response).to be_successful
      end

      it 'returns list of questions' do
        expect(json['questions'].size).to eq 2
      end

      it 'returns all public fields' do 
        %w[id title body created_at updated_at].each do |attr|
          expect(question_response[attr]).to eq question.send(attr).as_json
        end
      end

      it 'contains user object (author of the question)' do
        expect(question_response['author']['id']).to eq question.author.id
      end

      it 'contains short title' do
        expect(question_response['short_title']).to eq question.title.truncate(7)
      end

      describe 'answers' do
        let(:answer) { answers.first }
        let(:answer_response) { question_response['answers'].first }

        it 'returns list of answers' do
          expect(question_response['answers'].size).to eq 3
        end

        it 'returns all public fields' do 
          %w[id body created_at updated_at].each do |attr|
            expect(answer_response[attr]).to eq answer.send(attr).as_json
          end
        end
      end
    end
  end

  describe 'GET /api/v1/questions/id' do
    let!(:question) { create(:question) }
    let(:api_path) { "/api/v1/questions/#{question.id}" }

    it_behaves_like 'API Authorizable' do
      let(:method) { :get }
    end

    context 'authorized' do
      let(:access_token) { create(:access_token) }
      let(:question_response) { json['question'] }

      it 'returns all public fields' do
        get api_path,  params: { access_token: access_token.token }, headers: headers

        %w[id title body created_at updated_at].each do |attr|
          expect(question_response[attr]).to eq question.send(attr).as_json
        end
      end

      it_behaves_like 'API Linkable' do
        let(:resource) { question }
      end

      it_behaves_like 'API Commentable' do
        let(:resource) { question }
      end

      it_behaves_like 'API Attachable' do
        let!(:resource) { create(:question, :with_files )}
        let(:api_path) { "/api/v1/questions/#{resource.id}" }
      end
    end
  end

  describe 'POST /api/v1/questions/' do
    let(:headers) { { "ACCEPT" => 'application/json' } }
    let(:api_path) { "/api/v1/questions" }

    it_behaves_like 'API Authorizable' do
      let(:method) { :post }
    end

    context 'authorized' do
      let(:access_token) { create(:access_token) }
      let(:test_question_attribs) { { 'title' => 'Test question title', 'body' => 'test title body' } }
      let(:test_invalid_question_attribs) { { 'title' => 'Test question title', 'body' => '' } }

      it 'creates new question' do
        expect do
          post api_path, params: { access_token: access_token.token, question: attributes_for(:question) }, headers: headers
        end.to change(Question, :count).by(1)
      end

      it 'returns newly created question on success' do
        post api_path, params: { access_token: access_token.token, question: test_question_attribs }, headers: headers

        %w[title body].each do |attrib|
          expect(json['question'][attrib]).to eq test_question_attribs[attrib].as_json
        end
      end

      it 'returns unprocessible_entity on fail' do
        post api_path, params: { access_token: access_token.token, question: test_invalid_question_attribs }, headers: headers
        expect(response.status).to eq 422
      end

      it 'does not change questions count on fail' do
        expect do
          post api_path, params: { access_token: access_token.token, question: test_invalid_question_attribs }, headers: headers
        end.to_not change(Question, :count)
      end
    end
  end

  describe 'PATCH /api/v1/questions/:id' do
    let(:headers) { { "ACCEPT" => 'application/json' } }

    let(:user) { create(:user) }
    let!(:question) { create(:question, author: user) }

    let(:new_question_params) { {'title' => 'New question title', 'body' => 'New question body' } }
    let(:new_question_params_invalid) { {'title' => 'New question title', 'body' => '' } }
    let(:api_path) { api_v1_question_path(question) }

    it_behaves_like 'API Authorizable' do
      let(:method) { :patch }
    end

    context 'authorized' do
      let(:access_token_author) { create(:access_token, resource_owner_id: user.id) }
      let(:access_token_not_author) { create(:access_token) }

      it 'changes the question if the author of the request is the quthor of the question' do
        expect do
          patch api_path, params: { access_token: access_token_author.token, question: new_question_params }, headers: headers
          question.reload
        end.to change(question, :title).to(new_question_params['title'])
           .and change(question, :body).to(new_question_params['body'])
      end

      it 'returns the updated question on success' do
        patch api_path, params: { access_token: access_token_author.token, question: new_question_params }, headers: headers

        expect(json['question']['title']).to eq new_question_params['title']
        expect(json['question']['body']).to eq new_question_params['body']
      end

      it 'does not change the question attributes if the request author is not the author of the question' do
        RSpec::Matchers.define_negated_matcher :not_change, :change

        expect do
          patch api_path, params: { access_token: access_token_not_author.token, question: new_question_params }, headers: headers
        end.to not_change(question, :title).and not_change(question, :body)
      end

      it 'returns 403 forbidden when theh request author is not the author of the question' do
        patch api_path, params: { access_token: access_token_not_author.token, question: new_question_params }, headers: headers
        expect(response.status).to eq 403
      end

      it 'returns unprocessable_entity when the requested changes are not valid but performed by the author of the question' do
        patch api_path, params: { access_token: access_token_author.token, question: new_question_params_invalid }, headers: headers
        expect(response.status).to eq 422
      end
    end
  end

  describe 'DELETE /api/v1/questions/:id' do
    let(:headers) { { "ACCEPT" => 'application/json' } }

    let(:user) { create(:user) }
    let!(:question) { create(:question, author: user) }
    let(:api_path) { api_v1_question_path(question) }

    it_behaves_like 'API Authorizable' do
      let(:method) { :delete }
    end

    context 'authorized' do
      let(:access_token_author) { create(:access_token, resource_owner_id: user.id) }
      let(:access_token_not_author) { create(:access_token) }

      it 'returns ok when everything is ok' do
        delete api_path, params: { access_token: access_token_author.token }, headers: headers
        expect(response.status).to eq 200
      end

      it 'deletes the question' do
        expect do
          delete api_path, params: { access_token: access_token_author.token }, headers: headers
        end.to change(Question, :count).by(-1)
      end

      it 'returns 403 forbidden when the request author is not the author of the question' do
        delete api_path, params: { access_token: access_token_not_author.token }, headers: headers
        expect(response.status).to eq 403
      end
    end
  end
end

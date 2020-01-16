require 'rails_helper'

describe 'Answers API', type: :request do
  let(:headers) { { "CONTENT_TYPE" => "application/json",
                    "ACCEPT" => 'application/json' } }

  describe 'GET /api/v1/questions/:question_id/answers' do
    let!(:question) { create(:question) }
    let!(:answers) { create_list(:answer, 5, :different, question: question) }
    let(:api_path) { api_v1_question_answers_path(question) }

    it_behaves_like 'API Authorizable' do
      let(:method) { :get }
    end

    context 'authorized' do
      let(:access_token) { create(:access_token) }
      let(:answers_response) { json['answers'] }
      let(:first_answer_response) { answers_response.find { |ans| ans['id'] == answers.first.id } }

      before { get api_path, params: { access_token: access_token.token }, headers: headers }

      it 'returns all answers of the question' do
        expect(answers_response.size).to eq answers.size
      end

      it 'returns all the public fields' do
        %w[id body created_at updated_at].each do |attr|
          expect(first_answer_response[attr]).to eq answers.first.send(attr).as_json
        end
      end
    end
  end

  describe 'GET /api/v1/questions/answers/:id' do
    let!(:answer) { create(:answer) }
    let(:api_path) { api_v1_answer_path(answer) }

    it_behaves_like 'API Authorizable' do
      let(:method) { :get }
    end

    context 'authorized' do
      let(:access_token) { create(:access_token) }
      let(:answer_response) { json['answer'] }

      before { get api_path, params: { access_token: access_token.token }, headers: headers }

      it 'returns all public fields' do
        get api_path,  params: { access_token: access_token.token }, headers: headers

        %w[id body created_at updated_at].each do |attr|
          expect(answer_response[attr]).to eq answer.send(attr).as_json
        end
      end

      it_behaves_like 'API Linkable' do
        let(:resource) { answer }
      end

      it_behaves_like 'API Commentable' do
        let(:resource) { answer }
      end

      it_behaves_like 'API Attachable' do
        let!(:resource) { create(:answer, :with_files) }
        let(:api_path) { api_v1_answer_path(resource) }
      end
    end
  end

  describe 'POST /api/v1/questions/:question_id/answers' do
    let(:headers) { { "ACCEPT" => 'application/json' } }
    let!(:question) { create(:question) }
    let(:api_path) { api_v1_question_answers_path(question) }

    it_behaves_like 'API Authorizable' do
      let(:method) { :post }
    end

    context 'authorized' do
      let(:access_token) { create(:access_token) }
      let(:test_answer_attribs) { { 'body' => 'New test answer body' } }
      let(:test_invalid_answer_attribs) { { 'body' => '' } }

      it 'creates new answer for the given question' do
        expect do
          post api_path, params: { access_token: access_token.token, answer: attributes_for(:answer) }, headers: headers
        end.to change(question.answers, :count).by(1)
      end

      it 'returns newly created answer on success' do
        post api_path, params: { access_token: access_token.token, answer: test_answer_attribs }, headers: headers

        expect(json['answer']['body']).to eq test_answer_attribs['body'].as_json
      end

      it 'returns unprocessable_entity when proposed changes are invalid' do
        post api_path, params: { access_token: access_token.token, answer: test_invalid_answer_attribs }, headers: headers
        expect(response.status).to eq 422
      end

      it 'does not change answers count on fail' do
        expect do
          post api_path, params: { access_token: access_token.token, answer: test_invalid_answer_attribs }, headers: headers
        end.to_not change(question.answers, :count)
      end
    end
  end

  describe 'PATCH /api/v1/answer/:id' do
    let(:headers) { { "ACCEPT" => 'application/json' } }

    let(:user) { create(:user) }
    let!(:answer) { create(:answer, author: user) }

    let(:new_asnwer_params) { {'body' => 'New answer body' } }
    let(:new_asnwer_params_invalid) { {'body' => '' } }
    let(:api_path) { api_v1_answer_path(answer) }

    it_behaves_like 'API Authorizable' do
      let(:method) { :patch }
    end

    context 'authorized' do
      let(:access_token_author) { create(:access_token, resource_owner_id: user.id) }
      let(:access_token_not_author) { create(:access_token) }

      it 'changes the answer if the author of the request is the author of the answer' do
        expect do
          patch api_path, params: { access_token: access_token_author.token, answer: new_asnwer_params}, headers: headers
          answer.reload
        end.to change(answer, :body).to(new_asnwer_params['body'])
      end

      it 'returns the updated answer on success' do
        patch api_path, params: { access_token: access_token_author.token, answer: new_asnwer_params}, headers: headers
        expect(json['answer']['body']).to eq new_asnwer_params['body']
      end

      it 'returns the unprocessable_entity when proposed changes are invalid' do
        patch api_path, params: { access_token: access_token_author.token, answer: new_asnwer_params_invalid }, headers: headers
        expect(response.status).to eq 422
      end

      it 'returns 403 forbidden when the request author is not the author of the answer' do
        patch api_path, params: { access_token: access_token_not_author.token, answer: new_asnwer_params}, headers: headers
        expect(response.status).to eq 403
      end

      it 'does not change the answer attributes if the request author is not the author of the answer' do
        expect do
          patch api_path, params: { access_token: access_token_not_author.token, answer: new_asnwer_params }, headers: headers
        end.to_not change(answer, :body)
      end

      it 'does not change the answer if the request parameters are invalid' do
        expect do
          patch api_path, params: { access_token: access_token_author.token, answer: new_asnwer_params_invalid }, headers: headers
          answer.reload
        end.to_not change(answer, :body)
      end
    end
  end

  describe 'DELETE /api/v1/answer/:id' do
    let(:headers) { { "ACCEPT" => 'application/json' } }

    let(:user) { create(:user) }
    let!(:answer) { create(:answer, author: user) }
    let(:api_path) { api_v1_answer_path(answer) }

    it_behaves_like 'API Authorizable' do
      let(:method) { :delete }
    end

    context 'authorized' do
      let(:access_token_author) { create(:access_token, resource_owner_id: user.id) }
      let(:access_token_not_author) { create(:access_token) }

      it 'returns ok on success' do
        delete api_path, params: { access_token: access_token_author.token }, headers: headers
        expect(response.status).to eq 200
      end

      it 'deletes the answer' do
        expect do
          delete api_path, params: { access_token: access_token_author.token }, headers: headers
        end.to change(Answer, :count).by(-1)
      end

      it 'returns 403 forbidden when request author is not the answer author' do
        delete api_path, params: { access_token: access_token_not_author.token }, headers: headers
        expect(response.status).to eq 403
      end
    end
  end
end


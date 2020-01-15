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
end


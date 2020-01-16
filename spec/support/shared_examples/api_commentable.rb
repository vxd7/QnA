shared_examples_for 'API Commentable' do
  let!(:comments) { create_list(:comment, 3, :different, commentable: resource) }
  let(:resource_response) { json[resource.class.name.downcase] }
  let(:comments_response) { resource_response['comments'] }
  let(:comments_response_first) { comments_response.find { |l| l['id'] == comments.first.id } }

  context 'comments' do
    before { get api_path, params: { access_token: access_token.token }, headers: headers }

    it 'returns list of comments of the resource' do
      expect(comments_response.size).to eq comments.size
    end

    it 'returns all public fields' do
      %w[id body user_id created_at updated_at].each do |attr|
        expect(comments_response_first[attr]).to eq comments.first.send(attr).as_json
      end
    end
  end
end


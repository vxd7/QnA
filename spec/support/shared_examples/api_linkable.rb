shared_examples_for 'API Linkable' do
  let!(:links) { create_list(:link, 3, linkable: resource) }
  let(:resource_response) { json[resource.class.name.downcase] }
  let(:links_response) { resource_response['links'] }
  let(:links_response_first) { links_response.find { |l| l['id'] == links.first.id } }

  context 'links' do
    before { get api_path, params: { access_token: access_token.token }, headers: headers }

    it 'returns list of links of the resource' do
      expect(links_response.size).to eq links.size
    end

    it 'returns all public fields' do
      %w[id name url created_at updated_at].each do |attr|
        expect(links_response_first[attr]).to eq links.first.send(attr).as_json
      end
    end
  end
end

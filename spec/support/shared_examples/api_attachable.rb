shared_examples_for 'API Attachable' do
  let(:files) { resource.files }
  let(:resource_response) { json[resource.class.name.downcase] }
  let(:files_response) { resource_response['files'] }
  let(:files_response_first) { files_response.find { |r| r['id'] == files.first.id } }

  context 'files (urls only)' do
    before { get api_path, params: { access_token: access_token.token }, headers: headers }

    it 'returns list of file attachments of the resource' do
      expect(files_response.size).to eq files.size
    end

    it 'returns urls for every file' do
      files_response.each do |resp|
        expect(resp).to have_key('url')
      end
    end
  end
end

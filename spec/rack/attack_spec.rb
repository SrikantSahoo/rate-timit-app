require 'rails_helper'

RSpec.describe 'Rate limit Rule', type: :request, order: :defined do
  let (:rule) { YAML.load_file("#{Rails.root}/config/limit-rules.yml")[Rails.env] }

  it 'Sucessful response' do
    rule['max_requests'].times do
      get root_path
      expect(response).to be_successful
      expect(response.body).to eql('OK')
    end
  end

  it 'returns rate limit exceeded message' do
    get root_path
    expect(response).to_not be_successful
    expect(response).to have_http_status(429)
    expect(response.body).to match(/Rate limit exceeded/)
  end
end
require 'rails_helper'

RSpec.describe Api::V1::CrawlsController do
  it 'returns a crawl' do
    u = User.create!(email: 'u@u.com', password: 'something')
    crawl = Crawl.create!(name: 'my crawl', user: u, city: 'London')
    get "/api/v1/crawls/#{crawl.id}"
    response_data = JSON.parse(response.body)
    expect(response_data).to eq(
      'crawl' => {
        'id' => crawl.id,
        'name' => 'my crawl',
        'city' => 'London',
        'user_id' => u.id,
        'links' => {
          'stops' => "/api/v1/stops?crawl_id=#{crawl.id}"
        }
      }
    )
  end

  it 'crawl does not exist' do
    get '/api/v1/crawls/1'
    expect(response).to have_http_status(404)
  end
end

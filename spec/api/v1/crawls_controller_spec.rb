require 'rails_helper'

RSpec.describe Api::V1::CrawlsController do
  let(:user) { User.create!(email: 'u@u.com', password: 'something') }
  let(:auth_header) do
    generate_token(user)
  end

  it 'returns a crawl' do
    crawl = Crawl.create!(name: 'my crawl', user: user, city: 'London')
    get "/api/v1/crawls/#{crawl.id}"
    expect(response).to have_http_status(200)
    response_data = JSON.parse(response.body)
    expect(response_data).to eq(
      'crawl' => {
        'id' => crawl.id,
        'name' => 'my crawl',
        'city' => 'London',
        'user_id' => user.id,
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

  it 'can create a crawl' do
    post '/api/v1/crawls', {
      crawl: {
        name: 'Foo', city: 'bar'
      }
    }, auth_header
    expect(response).to have_http_status(201)
    response_data = JSON.parse(response.body)
    crawl = Crawl.last
    expect(response_data).to eq(
      'crawl' => {
        'id' => crawl.id,
        'name' => 'Foo',
        'city' => 'bar',
        'user_id' => user.id,
        'links' => {
          'stops' => "/api/v1/stops?crawl_id=#{crawl.id}"
        }
      })
  end

  it 'can not create a crawl with missing fields' do
    post '/api/v1/crawls', {
      crawl: {
        name: 'Foo'
      }
    }, auth_header
    expect(response).to have_http_status(422)
  end

  it 'can update a crawl' do
    crawl = Crawl.create!(name: "Crawl 1", city: "City 1", user: user)
    put "/api/v1/crawls/#{crawl.id}", {
      crawl: {
        name: 'Crawl 2', city: 'City 2'
      }
    }, auth_header
    expect(response).to have_http_status(200)
    response_data = JSON.parse(response.body)
    expect(response_data).to eq({})
    crawl.reload
    expect(crawl.name).to eq("Crawl 2")
    expect(crawl.city).to eq("City 2")
  end

  it 'can not update a crawl with bad data' do
    crawl = Crawl.create!(name: "Crawl 1", city: "City 1", user: user)
    put "/api/v1/crawls/#{crawl.id}", {
      crawl: {
        name: nil
      }
    }, auth_header
    expect(response).to have_http_status(422)
  end

  it 'rejects updates from wrong user' do
    user2 = User.create!(email: "a@a.com", password: "aaaaaaaa")
    crawl = Crawl.create!(name: "Crawl 1", city: "City 1", user: user2)
    put "/api/v1/crawls/#{crawl.id}", {
      crawl: {
        name: 'Crawl 2', city: 'City 2'
      }
    }, auth_header
    expect(response).to have_http_status(401)
  end
end

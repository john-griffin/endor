require 'rails_helper'

RSpec.describe Api::V1::CrawlsController do
  let(:user)  { User.create!(email: 'u@u.com', password: 'something') }
  let(:user2) { User.create!(email: 'a@a.com', password: 'aaaaaaaaa') }
  let(:auth_header) { generate_token(user) }

  context 'given an existing crawl' do
    let(:crawl) { Crawl.create!(name: 'my crawl', user: user, city: 'London') }

    it 'show action returns a crawl' do
      get "/api/v1/crawls/#{crawl.id}"
      expect(response).to have_http_status(200)
      response_data = JSON.parse(response.body)
      expect(response_data).to eq(
        'data' => {
          'id' => crawl.id.to_s,
          'name' => 'my crawl',
          'city' => 'London',
          'user-id' => user.id,
          'featured' => false,
          'image-url' => nil,
          'stop-count' => 0,
          'type' => 'crawls',
          'links' => {
            "self"=>"/api/v1/crawls/#{crawl.id}",
            "stops"=>{
              "self"=>"/api/v1/crawls/#{crawl.id}/links/stops",
              "related"=>"/api/v1/crawls/#{crawl.id}/stops"
            }
          }
        }
      )
    end

    it 'update action can update a crawl' do
      put "/api/v1/crawls/#{crawl.id}", {
        crawl: {
          name: 'Crawl 2', city: 'City 2'
        }
      }, auth_header
      expect(response).to have_http_status(200)
      response_data = JSON.parse(response.body)
      expect(response_data).to eq({})
      crawl.reload
      expect(crawl.name).to eq('Crawl 2')
      expect(crawl.city).to eq('City 2')
    end

    it 'update action is rejected with bad data' do
      put "/api/v1/crawls/#{crawl.id}", {
        crawl: {
          name: nil
        }
      }, auth_header
      expect(response).to have_http_status(422)
    end

    it 'update action rejects updates from invlaid user' do
      put "/api/v1/crawls/#{crawl.id}", {
        crawl: {
          name: 'Crawl 2', city: 'City 2'
        }
      }, generate_token(user2)
      expect(response).to have_http_status(401)
    end

    it 'destroy action can delete an owned crawl with associated stops' do
      v1 = Venue.create!(foursquare_id: 'blah', point: [1, 1])
      crawl.stops.create!(
        venue: v1, photo_prefix: 'a', photo_suffix: 'b', photo_id: 'c')
      delete "/api/v1/crawls/#{crawl.id}", {}, auth_header
      expect(response).to have_http_status(204)
    end

    it 'destroy action cannot delete someone elses crawl' do
      delete "/api/v1/crawls/#{crawl.id}", {}, generate_token(user2)
      expect(response).to have_http_status(401)
    end

    it 'destroy action cannot delete a crawl without authenticated' do
      delete "/api/v1/crawls/#{crawl.id}"
      expect(response).to have_http_status(401)
    end
  end

  it 'show action fails when crawl does not exist' do
    get '/api/v1/crawls/1'
    expect(response).to have_http_status(404)
  end

  it 'create action can create a crawl' do
    post '/api/v1/crawls', {
      crawl: {
        name: 'Foo', city: 'bar', image_url: 'foo.jpg'
      }
    }, auth_header
    expect(response).to have_http_status(201)
    response_data = JSON.parse(response.body)
    crawl = Crawl.last
    expect(response_data).to eq(
      'data' => {
        'id' => crawl.id.to_s,
        'name' => 'Foo',
        'city' => 'bar',
        'user-id' => user.id,
        'featured' => false,
        'image-url' => 'foo.jpg',
        'stop-count' => 0,
        'type' => 'crawls',
        'links' => {
          "self"=>"/api/v1/crawls/#{crawl.id}",
          "stops"=>{
            "self"=>"/api/v1/crawls/#{crawl.id}/links/stops",
            "related"=>"/api/v1/crawls/#{crawl.id}/stops"
          }
        }
      })
  end

  it 'create action is rejected when fields are missing' do
    post '/api/v1/crawls', {
      crawl: {
        name: 'Foo'
      }
    }, auth_header
    expect(response).to have_http_status(422)
  end

  context 'given some featured and personal crawls' do
    let!(:crawl1) do
      Crawl.create!(name: 'Crawl 1', city: 'London', user: user, featured: true)
    end
    let!(:crawl2) do
      Crawl.create!(name: 'Crawl 2', city: 'London', user: user2)
    end
    let!(:crawl3) do
      Crawl.create!(name: 'Crawl 3', city: 'New York', user: user)
    end
    before(:each) do
      Crawl.create!(
        name: 'Crawl 4', city: 'New York', user: user2, featured: true)
    end

    it 'index action returns only featured crawls when not logged in' do
      get '/api/v1/crawls'
      expect(response).to have_http_status(200)
      response_data = JSON.parse(response.body)
      expect(response_data['data'].count).to eq(2)
      expect(response_data['data']).to start_with(
        'id' => crawl1.id.to_s,
        'name' => 'Crawl 1',
        'city' => 'London',
        'user-id' => user.id,
        'featured' => true,
        'image-url' => nil,
        'stop-count' => 0,
        'type' => 'crawls',
        'links' => {
          "self" => "/api/v1/crawls/#{crawl1.id}",
          "stops" => {
            "self" => "/api/v1/crawls/#{crawl1.id}/links/stops",
            "related" => "/api/v1/crawls/#{crawl1.id}/stops"
          }
        }
      )
    end

    it 'index action returns featured and owned crawls when logged in' do
      get '/api/v1/crawls', {}, auth_header
      expect(response).to have_http_status(200)
      response_data = JSON.parse(response.body)
      expect(response_data['data'].count).to eq(3)
      expect(response_data['data']).to include(
        'id' => crawl3.id.to_s,
        'name' => 'Crawl 3',
        'city' => 'New York',
        'user-id' => user.id,
        'featured' => false,
        'image-url' => nil,
        'stop-count' => 0,
        'type' => 'crawls',
        'links' => {
          "self" => "/api/v1/crawls/#{crawl3.id}",
          "stops" => {
            "self" => "/api/v1/crawls/#{crawl3.id}/links/stops",
            "related" => "/api/v1/crawls/#{crawl3.id}/stops"
          }
        }
      )
    end
  end
end

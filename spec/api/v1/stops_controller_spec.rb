require 'rails_helper'

RSpec.describe Api::V1::StopsController do
  context 'given some stops, venues and crawl' do
    let(:stop1) do
      venue1 = Venue.create(
        name: 'venue1',
        description: 'desc 1',
        photo_url: 'http://example.com/image1.png',
        location: ['address1', 'address 2'],
        foursquare_id: 'id1'
      )
      Stop.new(name: 'stop 1', venue: venue1, row_order_position: 'last')
    end
    let(:stop2) do
      venue2 = Venue.create(
        name: 'venue2',
        description: 'desc 2',
        photo_url: 'http://example.com/image2.png',
        location: ['address3', 'address 4', 'address 5'],
        foursquare_id: 'id2'
      )
      Stop.new(name: 'stop 2', venue: venue2, row_order_position: 'last')
    end
    let!(:crawl) { Crawl.create!(name: 'my crawl', stops: [stop1, stop2]) }

    it 'can fetch a single stop' do
      get "/api/v1/stops/#{stop1.id}"
      expect(response).to have_http_status(200)
      response_data = JSON.parse(response.body)
      expect(response_data).to eq(
        'stop' => {
          'id' => stop1.id,
          'row_order' => stop1.row_order,
          'name' => 'stop 1',
          'venue_name' => 'venue1',
          'description' => 'desc 1',
          'photo_url' => 'http://example.com/image1.png',
          'location' => ['address1', 'address 2'],
          'foursquare_id' => 'id1'
        }
      )
    end

    it 'returns stops and venues for a crawl' do
      get '/api/v1/stops',  crawl_id: crawl.id
      response_data = JSON.parse(response.body)
      expect(response_data).to eq('stops' => [
        {
          'id' => stop1.id,
          'row_order' => stop1.row_order,
          'name' => 'stop 1',
          'venue_name' => 'venue1',
          'description' => 'desc 1',
          'photo_url' => 'http://example.com/image1.png',
          'location' => ['address1', 'address 2'],
          'foursquare_id' => 'id1'
        },
        {
          'id' => stop2.id,
          'row_order' => stop2.row_order,
          'name' => 'stop 2',
          'venue_name' => 'venue2',
          'description' => 'desc 2',
          'photo_url' => 'http://example.com/image2.png',
          'location' => ['address3', 'address 4', 'address 5'],
          'foursquare_id' => 'id2'
        }
      ])
    end

    it 'can update a stop and return updated details' do
      expect(stop1.row_order).to be < stop2.row_order
      put "/api/v1/stops/#{stop1.id}", stop: {
        'name' => 'stop 1 updated',
        'venue_name' => 'venue1',
        'description' => 'desc 1',
        'photo_url' => 'http://example.com/image1.png',
        'location' => ['address1', 'address 2'],
        'foursquare_id' => 'id47',
        'row_order_position' => 'down'
      }
      expect(response).to have_http_status(200)
      response_data = JSON.parse(response.body)
      expect(response_data['stop']['name']).to eq('stop 1 updated')
      expect(response_data['stop']['foursquare_id']).to eq('id47')
      expect(response_data['stop']['row_order']).to be > stop2.row_order
    end

    it "can't set bad params" do
      put "/api/v1/stops/#{stop1.id}", stop: {
        'name' => 'stop 1 updated',
        'venue_name' => 'venue1',
        'description' => 'desc 1',
        'photo_url' => 'http://example.com/image1.png',
        'location' => ['address1', 'address 2'],
        'foursquare_id' => nil,
        'row_order_position' => 'blerg'
      }
      expect(response).to have_http_status(422)
    end

    it "can delete a stop" do
      delete "/api/v1/stops/#{stop1.id}"
      expect(Stop.where(id: stop1.id)).to be_empty
      expect(response).to have_http_status(204)
    end

    it "can't delete a stop that doesn't exist" do
      delete "/api/v1/stops/47"
      expect(response).to have_http_status(404)
    end
  end

  it 'returns 422 if crawl id is missing' do
    get '/api/v1/stops'
    expect(response).to have_http_status(422)
  end

  it 'returns empty array if no results' do
    get '/api/v1/stops?crawl_id=2'
    response_data = JSON.parse(response.body)
    expect(response_data).to eq('stops' => [])
  end

  def expected_stop(stop)
    { 'stop' => {
      'id' => stop.id,
      'row_order' => stop.row_order,
      'name' => 'foo',
      'venue_name' => 'B.B. King Blues Club & Grill',
      'description' => "B.B. King's Blues Club & Grill is the premier",
      'photo_url' => 'https://irs3.4sqi.net/img/general/width300/52909181_Mrpsi_KnrVUAI5tzdgesZ3SWasHfplIYmQnQNBFYU5k.jpg',
      'location' => ['237 W 42nd St', 'New York, NY 10036', 'United States'],
      'foursquare_id' => '410c3280f964a520b20b1fe3'
    } }
  end

  it 'given existing crawl, it creates a stop and venue' do
    crawl = Crawl.create!(name: 'my crawl')
    post '/api/v1/stops', 'stop' => {
      'name' => 'foo',
      'description' => "B.B. King's Blues Club & Grill is the premier",
      'foursquare_id' => '410c3280f964a520b20b1fe3',
      'photo_url' => 'https://irs3.4sqi.net/img/general/width300/52909181_Mrpsi_KnrVUAI5tzdgesZ3SWasHfplIYmQnQNBFYU5k.jpg',
      'location' => ['237 W 42nd St', 'New York, NY 10036', 'United States'],
      'venue_name' => 'B.B. King Blues Club & Grill',
      'row_order' => nil, # ember app sends through nil row_order
      'row_order_position' => 'last',
      'crawl_id' => crawl.id
    }
    response_data = JSON.parse(response.body)
    stop = Stop.first
    expect(response_data).to eq(expected_stop(stop))
    expect(stop.venue.name).to eq('B.B. King Blues Club & Grill')
  end

  it 'given existing crawl and venue, it creates a stop and reuses venue' do
    Venue.create!(
      name: 'B.B. King Blues Club & Grill',
      'foursquare_id' => '410c3280f964a520b20b1fe3',
      'location' => ['237 W 42nd St', 'New York, NY 10036', 'United States'],
      'photo_url' => 'https://irs3.4sqi.net/img/general/width300/52909181_Mrpsi_KnrVUAI5tzdgesZ3SWasHfplIYmQnQNBFYU5k.jpg',
      'description' => "B.B. King's Blues Club & Grill is the premier"
    )
    crawl = Crawl.create!(name: 'my crawl')
    post '/api/v1/stops', 'stop' => {
      'name' => 'foo',
      'description' => 'this will be replaced by existing description',
      'foursquare_id' => '410c3280f964a520b20b1fe3',
      'photo_url' => 'https://irs3.4sqi.net/img/general/width300/52909181_Mrpsi_KnrVUAI5tzdgesZ3SWasHfplIYmQnQNBFYU5k.jpg',
      'location' => ['237 W 42nd St', 'New York, NY 10036', 'United States'],
      'venue_name' => 'B.B. King Blues Club & Grill',
      'row_order' => nil, # ember app sends through nil row_order
      'row_order_position' => 'last',
      'crawl_id' => crawl.id
    }
    response_data = JSON.parse(response.body)
    stop = Stop.first
    expect(response_data).to eq(expected_stop(stop))
    expect(stop.venue.name).to eq('B.B. King Blues Club & Grill')
    expect(Venue.count).to eq(1)
  end

  it 'cannot create a stop without a crawl' do
    post '/api/v1/stops', 'stop' => {
      'name' => 'foo',
      'description' => 'this will be replaced by existing description'
    }
    expect(response).to have_http_status(422)
  end

  it 'cannot create a stop without a venue' do
    crawl = Crawl.create!(name: 'my crawl')
    post '/api/v1/stops', 'stop' => {
      'name' => 'foo',
      'description' => 'this will be replaced by existing description',
      'crawl_id' => crawl.id
    }
    expect(response).to have_http_status(422)
  end
end

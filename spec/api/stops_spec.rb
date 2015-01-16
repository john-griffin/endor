require 'rails_helper'

RSpec.describe "Stops API", :type => :request do
  it "returns stops and venues for a crawl" do
    venue1 = Venue.create(
      name: 'venue1',
      description: 'desc 1',
      photo_url: 'http://example.com/image1.png',
      location: ['address1', 'address 2'],
      foursquare_id: 'id1'
    )
    venue2 = Venue.create(
      name: 'venue2',
      description: 'desc 2',
      photo_url: 'http://example.com/image2.png',
      location: ['address3', 'address 4', 'address 5'],
      foursquare_id: 'id2'
    )
    stop1 = Stop.create!(name: 'stop 1', venue: venue1)
    stop2 = Stop.create!(name: 'stop 2', venue: venue2)
    crawl = Crawl.create!(name: 'my crawl', stops: [stop1, stop2])
    get "/api/v1/stops", { crawl_id: crawl.id }
    response_data = JSON.parse(response.body)
    expect(response_data).to eq({"stops"=>[
      {
        "id"=>stop1.id,
        "name"=>"stop 1",
        "venue_name"=>"venue1",
        "description"=>"desc 1",
        "photo_url"=>"http://example.com/image1.png",
        "location"=>["address1", "address 2"],
        "foursquare_id"=>"id1"
      },
      {
        "id"=>stop2.id,
        "name"=>"stop 2",
        "venue_name"=>"venue2",
        "description"=>"desc 2",
        "photo_url"=>"http://example.com/image2.png",
        "location"=>["address3", "address 4", "address 5"],
        "foursquare_id"=>"id2"
      }
    ]})
  end

  it "returns 422 if crawl id is missing" do
    get "/api/v1/stops"
    expect(response).to have_http_status(422)
  end

  it "returns empty array if no results" do
    get "/api/v1/stops?crawl_id=2"
    response_data = JSON.parse(response.body)
    expect(response_data).to eq("stops"=>[])
  end
end
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
        "row_order"=>stop1.row_order,
        "name"=>"stop 1",
        "venue_name"=>"venue1",
        "description"=>"desc 1",
        "photo_url"=>"http://example.com/image1.png",
        "location"=>["address1", "address 2"],
        "foursquare_id"=>"id1"
      },
      {
        "id"=>stop2.id,
        "row_order"=>stop2.row_order,
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

  it "given existing crawl, it creates a stop and venue" do
    crawl = Crawl.create!(name: 'my crawl')
    post '/api/v1/stops', {"stop"=>{
      "name"=>"foo",
      "description"=>"B.B. King's Blues Club & Grill is the premier live music venue & restaurant in the heart of Times Square.",
      "foursquare_id"=>"410c3280f964a520b20b1fe3",
      "photo_url"=>"https://irs3.4sqi.net/img/general/width300/52909181_Mrpsi_KnrVUAI5tzdgesZ3SWasHfplIYmQnQNBFYU5k.jpg",
      "location"=>["237 W 42nd St (btwn 7th & 8th Ave)","New York, NY 10036","United States"],
      "venue_name"=>"B.B. King Blues Club & Grill",
      "row_order"=>nil, # ember app sends through nil row_order
      "row_order_position"=>"last",
      "crawl_id"=>crawl.id
    }}
    response_data = JSON.parse(response.body)
    stop = Stop.first
    expect(response_data).to eq({"stop"=>{
      "id"=>stop.id,
      "row_order"=>stop.row_order,
      "name"=>"foo",
      "venue_name"=>"B.B. King Blues Club & Grill",
      "description"=>"B.B. King's Blues Club & Grill is the premier live music venue & restaurant in the heart of Times Square.",
      "photo_url"=>"https://irs3.4sqi.net/img/general/width300/52909181_Mrpsi_KnrVUAI5tzdgesZ3SWasHfplIYmQnQNBFYU5k.jpg",
      "location"=>["237 W 42nd St (btwn 7th & 8th Ave)", "New York, NY 10036", "United States"],
      "foursquare_id"=>"410c3280f964a520b20b1fe3"
    }})
    expect(stop.venue.name).to eq("B.B. King Blues Club & Grill")
  end

  it "given existing crawl and venue, it creates a stop and reuses venue" do
    venue = Venue.create!(
      name: "B.B. King Blues Club & Grill",
      "foursquare_id"=>"410c3280f964a520b20b1fe3",
      "location"=>["237 W 42nd St (btwn 7th & 8th Ave)","New York, NY 10036","United States"],
      "photo_url"=>"https://irs3.4sqi.net/img/general/width300/52909181_Mrpsi_KnrVUAI5tzdgesZ3SWasHfplIYmQnQNBFYU5k.jpg",
      "description"=>"B.B. King's Blues Club & Grill is the premier live music venue & restaurant in the heart of Times Square."
    )
    crawl = Crawl.create!(name: 'my crawl')
    post '/api/v1/stops', {"stop"=>{
      "name"=>"foo",
      "description"=>"this will be replaced by existing description",
      "foursquare_id"=>"410c3280f964a520b20b1fe3",
      "photo_url"=>"https://irs3.4sqi.net/img/general/width300/52909181_Mrpsi_KnrVUAI5tzdgesZ3SWasHfplIYmQnQNBFYU5k.jpg",
      "location"=>["237 W 42nd St (btwn 7th & 8th Ave)","New York, NY 10036","United States"],
      "venue_name"=>"B.B. King Blues Club & Grill",
      "row_order"=>nil, # ember app sends through nil row_order
      "row_order_position"=>"last",
      "crawl_id"=>crawl.id
    }}
    response_data = JSON.parse(response.body)
    stop = Stop.first
    expect(response_data).to eq({"stop"=>{
      "id"=>stop.id,
      "row_order"=>stop.row_order,
      "name"=>"foo",
      "venue_name"=>"B.B. King Blues Club & Grill",
      "description"=>"B.B. King's Blues Club & Grill is the premier live music venue & restaurant in the heart of Times Square.",
      "photo_url"=>"https://irs3.4sqi.net/img/general/width300/52909181_Mrpsi_KnrVUAI5tzdgesZ3SWasHfplIYmQnQNBFYU5k.jpg",
      "location"=>["237 W 42nd St (btwn 7th & 8th Ave)", "New York, NY 10036", "United States"],
      "foursquare_id"=>"410c3280f964a520b20b1fe3"
    }})
    expect(stop.venue.name).to eq("B.B. King Blues Club & Grill")
    expect(Venue.count).to eq(1)
  end
end
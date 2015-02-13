require 'rails_helper'

RSpec.describe Api::V1::SessionsController do
  it 'create action sign a user in' do
    u = User.create!(email: 'u@u.com', password: 'something')
    post '/api/v1/sessions', 'user' => {
      'email' => 'u@u.com', 'password' => 'something'
    }
    expect(response).to have_http_status(201)
    response_data = JSON.parse(response.body)
    expect(response_data).to eq(
      'token' => u.authentication_token,
      'email' => 'u@u.com',
      'id' => u.id
    )
  end

  it 'create action can be rejected with bad credentials' do
    post '/api/v1/sessions', 'user' => {
      'email' => 'u@u.com', 'password' => 'something'
    }
    expect(response).to have_http_status(401)
  end
end

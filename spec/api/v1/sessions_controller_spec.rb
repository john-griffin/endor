require 'rails_helper'

RSpec.describe Api::V1::SessionsController do
  it 'can log in' do
    u = User.create!(email: 'u@u.com', password: 'something')
    post '/api/v1/sessions', 'user' => {
      'email' => 'u@u.com', 'password' => 'something'
    }
    expect(response).to have_http_status(201)
    response_data = JSON.parse(response.body)
    expect(response_data).to eq(
      'authentication_token' => u.authentication_token, 'email' => 'u@u.com')
  end
end

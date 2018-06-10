require 'rails_helper'

RSpec.describe Api::V1::LinksController, type: :request do
  describe 'GET /links' do

  end

  describe 'CREATE /links' do
    let(:long_url) { 'https://long.url.com/shorten/me?something=1&anotherParam=42' }

    context 'when a custom slug is provided' do
      let(:params) do
        { link: { slug: 'custom-slug', url: long_url } }
      end

      before do
        post api_v1_links_path, params: params, as: :json
      end

      it 'creates the resource' do
        expect(response).to have_http_status(:created)
      end

      it 'responds with the short_url' do
        expect(json_response[:data][:short_url]).to eq('http://www.example.com/custom-slug')
      end

      it 'responds with the original url' do
        expect(json_response[:data][:url]).to eq(long_url)
      end
    end

    context 'when an invalid custom slug is provided' do
      let(:params) do
        { link: { slug: '!!!invalid@@@', url: long_url } }
      end

      before do
        post api_v1_links_path, params: params, as: :json
      end

      it 'responds with a bad_request' do
        expect(response).to have_http_status(:bad_request)
        expect(json_response[:errors]).to include(/Slug can only include/)
      end
    end

    context 'when no custom slug is provided' do
      let(:params) do
        { link: { url: long_url } }
      end

      before do
        post api_v1_links_path, params: params, as: :json
      end

      it 'creates the resource' do
        expect(response).to have_http_status(:created)
      end

      it 'responds with a generated short_url' do
        expect(json_response[:data][:short_url]).to be_present
      end

      it 'responds with the original url' do
        expect(json_response[:data][:url]).to eq(long_url)
      end
    end

    context 'when a duplicate slug is provided' do
      let(:params) do
        { link: { slug: 'some-slug', url: long_url } }
      end

      before do
        Link.create!(slug: 'some-slug', url: 'http://someother.url.com/')
        post api_v1_links_path, params: params, as: :json
      end

      it 'responds with a bad_request' do
        expect(response).to have_http_status(:bad_request)
        expect(json_response[:errors]).to include('Slug has already been taken')
      end
    end

    context 'when no url is provided' do
      let(:params) do
        { link: { url: '' } }
      end

      before do
        post api_v1_links_path, params: params, as: :json
      end

      it 'responds with a bad_request' do
        expect(response).to have_http_status(:bad_request)
        expect(json_response[:errors]).to include("Url can't be blank")
      end
    end

    context 'when a duplicate url is provided' do
      let(:params) do
        { link: { url: long_url } }
      end

      before do
        Link.create(url: long_url)
        post api_v1_links_path, params: params, as: :json
      end

      it 'responds with a bad_request' do
        expect(response).to have_http_status(:bad_request)
        expect(json_response[:errors]).to include('Url has already been taken')
      end
    end
  end
end

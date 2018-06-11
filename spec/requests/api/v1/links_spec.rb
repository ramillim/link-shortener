# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Api::V1::LinksController, type: :request do
  let(:long_url) { 'https://long.url.com/shorten/me?something=1&anotherParam=42' }

  describe 'GET /api/v1/links' do
    let!(:short_link) { Link.create!(url: long_url) }

    context 'when an existing resource is requested' do
      it 'responds with ok' do
        get api_v1_link_path(short_link.slug), as: :json
        expect(response).to have_http_status(:ok)
      end

      context 'the response body contains' do
        before do
          get api_v1_link_path(short_link.slug), as: :json
        end

        it 'the short_url' do
          expect(json_response[:data][:short_url]).to eq("http://www.example.com/#{short_link.slug}")
        end

        it 'the original url' do
          expect(json_response[:data][:url]).to eq(long_url)
        end

        xit 'the number of times the link has been visited total' do
        end

        xit 'a histogram of the number of visits per day' do
        end
      end
    end

    context 'when a non-existent resource is requested' do
      it 'responds with data about the link' do
        get api_v1_link_path('not-found'), as: :json
        expect(response).to have_http_status(:not_found)
      end
    end
  end

  describe 'CREATE /api/v1/links' do
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
